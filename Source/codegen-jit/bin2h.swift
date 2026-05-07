// Generates cuda_jit_sources.h by embedding CUDA device header files as C
// byte arrays. Swift equivalent of mlx/backend/cuda/bin2h.cmake.

import ArgumentParser
import Foundation

enum Format: String, ExpressibleByArgument {
    case cpp
    case h
    case inc // standalone header with array defined as constexpr
}

func bin2h(sourceFiles: [URL], variableName: String, namespace: String, outputFile: URL, format: Format) throws {
    var arrayDefinition = ""

    for file in sourceFiles {
        let nameWE       = file.deletingPathExtension().lastPathComponent
        let validName    = makeCIdentifier(nameWE)
        let fullVarName  = "\(variableName)_\(validName)"

        if format == .h {
            arrayDefinition += "extern constinit const char *\(fullVarName);\n"
        } else {
            var data = try Data(contentsOf: file)
            data.append(0x00)                    // null-terminate (NULL_TERMINATE flag)
            data = stripCopyright(data)

            let body = formatByteArray(data)
            if format == .inc {
                arrayDefinition += "constexpr char \(fullVarName)[] = {\n\(body)\n};\n\n"
            } else {
                arrayDefinition += "extern constinit const char \(fullVarName)[] = {\n\(body)\n};\n\n"
            }
        }
    }

    if format == .h {
        arrayDefinition += "\n"
    }

    let head = format != .cpp ? "#pragma once\n\n" : ""

    let body = head + """
        namespace \(namespace) {

        \(arrayDefinition)} // namespace \(namespace)

        """

    try body.write(to: outputFile, atomically: true, encoding: .utf8)
}

private func makeCIdentifier(_ name: String) -> String {
    var result = ""
    for (i, ch) in name.unicodeScalars.enumerated() {
        let isLetter = CharacterSet.letters.union(CharacterSet(charactersIn: "_")).contains(ch)
        let isDigit  = CharacterSet.decimalDigits.contains(ch)
        if isLetter || (isDigit && i > 0) {
            result.unicodeScalars.append(ch)
        } else if isDigit {
            result += "_"
            result.unicodeScalars.append(ch)
        } else {
            result += "_"
        }
    }
    return result
}

// Replace each occurrence of the byte pair [0xC2, 0xA9] (UTF-8 for ©) with
// [0x20, 0x20] (two ASCII spaces), matching the CMake `c2a9 → 2020` hex
// substitution done before the byte-array formatting step.
func stripCopyright(_ data: Data) -> Data {
    var bytes = Array(data)
    var i = 0
    while i + 1 < bytes.count {
        if bytes[i] == 0xC2 && bytes[i + 1] == 0xA9 {
            bytes[i]     = 0x20
            bytes[i + 1] = 0x20
            i += 2
        } else {
            i += 1
        }
    }
    return Data(bytes)
}

// Format bytes as a C initialiser body, 12 bytes per line (= 24 hex chars),
// matching the `wrap_string(AT_COLUMN 24)` + pair-regex pass in bin2h.cmake.
private func formatByteArray(_ data: Data) -> String {
    let bytesPerLine = 12
    var lines: [String] = []
    var i = data.startIndex
    while i < data.endIndex {
        let end = data.index(i, offsetBy: bytesPerLine, limitedBy: data.endIndex) ?? data.endIndex
        let chunk = data[i..<end].map { String(format: " 0x%02x,", $0) }.joined()
        lines.append(" \(chunk)")   // leading space matches wrap_string's "\n "
        i = end
    }
    return lines.joined(separator: "\n")
}
