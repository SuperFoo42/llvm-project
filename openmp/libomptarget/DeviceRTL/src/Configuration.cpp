//===- Configuration.cpp - OpenMP device configuration interface -- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the data object of the constant device environment and the
// query API.
//
//===----------------------------------------------------------------------===//

#include "Configuration.h"
#include "State.h"
#include "Types.h"

using namespace ompx;

#pragma omp begin declare target device_type(nohost)

// defined by CGOpenMPRuntimeGPU
extern uint32_t __omp_rtl_debug_kind;
extern uint32_t __omp_rtl_assume_no_thread_state;
extern uint32_t __omp_rtl_assume_no_nested_parallelism;

// This variable should be visibile to the plugin so we override the default
// hidden visibility.
[[gnu::used, gnu::retain, gnu::weak,
  gnu::visibility("protected")]] DeviceEnvironmentTy
    CONSTANT(__omp_rtl_device_environment);

uint32_t config::getDebugKind() {
  return __omp_rtl_debug_kind & __omp_rtl_device_environment.DeviceDebugKind;
}

uint32_t config::getNumDevices() {
  return __omp_rtl_device_environment.NumDevices;
}

uint32_t config::getDeviceNum() {
  return __omp_rtl_device_environment.DeviceNum;
}

uint64_t config::getDynamicMemorySize() {
  return __omp_rtl_device_environment.DynamicMemSize;
}

uint64_t config::getClockFrequency() {
  return __omp_rtl_device_environment.ClockFrequency;
}

void *config::getIndirectCallTablePtr() {
  return reinterpret_cast<void *>(
      __omp_rtl_device_environment.IndirectCallTable);
}

uint64_t config::getHardwareParallelism() {
  return __omp_rtl_device_environment.HardwareParallelism;
}

uint64_t config::getIndirectCallTableSize() {
  return __omp_rtl_device_environment.IndirectCallTableSize;
}

bool config::isDebugMode(DeviceDebugKind Kind) {
  return config::getDebugKind() & uint32_t(Kind);
}

bool config::mayUseThreadStates() { return !__omp_rtl_assume_no_thread_state; }

bool config::mayUseNestedParallelism() {
  if (__omp_rtl_assume_no_nested_parallelism)
    return false;
  return state::getKernelEnvironment().Configuration.MayUseNestedParallelism;
}

#pragma omp end declare target
