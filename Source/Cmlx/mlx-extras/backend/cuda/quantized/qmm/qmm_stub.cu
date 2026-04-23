// Copyright © 2026 Apple Inc.

// Stub implementation of the qmm kernels for fast compilation.
// All supports_* functions return false so no kernel is ever dispatched.
// Enable with -DMLX_QMM_STUB=ON at cmake configure time.

#include "mlx/backend/cuda/quantized/qmm/qmm.h"

#include <stdexcept>

namespace mlx::core {

bool supports_qmm_sm90(
    const array&,
    const array&,
    const array&,
    const std::optional<array>&,
    const array&,
    bool,
    int,
    int,
    QuantizationMode,
    cu::Device&) {
  return false;
}

void qmm_sm90(
    const array&,
    const array&,
    const array&,
    const array&,
    array&,
    int,
    int,
    cu::CommandEncoder&,
    Stream) {
  throw std::runtime_error("[qmm_sm90] stub build — kernel not compiled");
}

bool supports_qmm_sm80(
    const array&,
    const array&,
    const array&,
    const std::optional<array>&,
    const array&,
    bool,
    int,
    int,
    QuantizationMode,
    cu::Device&) {
  return false;
}

void qmm_sm80(
    const array&,
    const array&,
    const array&,
    const std::optional<array>&,
    const std::optional<array>&,
    const std::optional<array>&,
    array&,
    int,
    int,
    QuantizationMode,
    cu::CommandEncoder&) {
  throw std::runtime_error("[qmm_sm80] stub build — kernel not compiled");
}

bool supports_qmm_naive(
    const array&,
    const array&,
    const array&,
    const std::optional<array>&,
    const array&,
    bool,
    int,
    int,
    QuantizationMode,
    cu::Device&) {
  return false;
}

void qmm_naive(
    const array&,
    const array&,
    const array&,
    const std::optional<array>&,
    const std::optional<array>&,
    const std::optional<array>&,
    array&,
    bool,
    int,
    int,
    QuantizationMode,
    cu::CommandEncoder&) {
  throw std::runtime_error("[qmm_naive] stub build — kernel not compiled");
}

bool supports_fp_qmv(
    const array&,
    const array&,
    const array&,
    const std::optional<array>&,
    const array&,
    bool,
    int,
    int,
    QuantizationMode,
    cu::Device&) {
  return false;
}

void fp_qmv(
    const array&,
    const array&,
    const array&,
    array&,
    int,
    int,
    cu::CommandEncoder&,
    Stream) {
  throw std::runtime_error("[fp_qmv] stub build — kernel not compiled");
}

bool supports_qmv(
    const array&,
    const array&,
    const array&,
    const std::optional<array>&,
    const array&,
    bool,
    int,
    int,
    QuantizationMode,
    cu::Device&) {
  return false;
}

void qmv(
    const array&,
    const array&,
    const array&,
    const std::optional<array>&,
    array&,
    int,
    int,
    QuantizationMode,
    cu::CommandEncoder&) {
  throw std::runtime_error("[qmv] stub build — kernel not compiled");
}

void gather_qmv(
    const array&,
    const array&,
    const array&,
    const std::optional<array>&,
    const array&,
    const array&,
    array&,
    int,
    int,
    QuantizationMode,
    cu::CommandEncoder&) {
  throw std::runtime_error("[gather_qmv] stub build — kernel not compiled");
}

} // namespace mlx::core
