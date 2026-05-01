import ArgumentParser
import Foundation

@main
struct CodegenJit: ParsableCommand {
    @Argument(help: "Input files")
    var inputs: [String] = []

    @Option(name: .short, help: "Output files")
    var outputs: [String] = []

    @Option(name: .long, help: "Output format: cpp (default), h, or inc")
    var format: Format = .cpp

    func run() throws {
        guard outputs.count == 1, let output = outputs.first else {
            throw ValidationError("Unexpeted output files: \(outputs)")
        }
        let outputUrl = URL(fileURLWithPath: output)
        try FileManager.default.createDirectory(at: outputUrl.deletingLastPathComponent(), withIntermediateDirectories: true)

        // Non-recursive glob of *.h and *.cuh (mirrors file(GLOB ... device/*.h device/*.cuh) in CMakeLists.txt)
        let fm = FileManager.default
        var sourceFiles: [URL] = []
        for input in inputs {
            let url = URL(fileURLWithPath: input)
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: url.path, isDirectory: &isDir) else {
                throw ValidationError("Input not found: \(url.path)")
            }
            if isDir.boolValue {
                guard let iter = fm.enumerator(
                    at: url,
                    includingPropertiesForKeys: [.isRegularFileKey],
                    options: .skipsSubdirectoryDescendants
                ) else {
                    throw ValidationError("Cannot enumerate \(url.path)")
                }
                for case let fileURL as URL in iter {
                    let ext = fileURL.pathExtension
                    if ext == "h" || ext == "cuh" {
                        sourceFiles.append(fileURL)
                    }
                }
            } else {
                sourceFiles.append(url)
            }
        }

        sourceFiles.sort { $0.lastPathComponent < $1.lastPathComponent }

        if sourceFiles.isEmpty {
            throw ValidationError("No .h or .cuh files found in \(inputs)")
        }

        try fm.createDirectory(at: outputUrl.deletingLastPathComponent(),
                            withIntermediateDirectories: true)

        try bin2h(
            sourceFiles: sourceFiles,
            variableName: "jit_source",
            namespace: "mlx::core",
            outputFile: outputUrl,
            format: format
        )

        print("Generated \(outputUrl.path) (\(sourceFiles.count) source files embedded)")
    }
}
