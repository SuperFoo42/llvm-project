//===-- Implementation of crt for amdgpu ----------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/__support/GPU/utils.h"
#include "src/__support/RPC/rpc_client.h"
#include "src/stdlib/atexit.h"
#include "src/stdlib/exit.h"

extern "C" int main(int argc, char **argv, char **envp);

namespace __llvm_libc {

// The AMDGPU architecture provides a fixed frequency clock used for obtaining
// real time. However, the frequency of this clock varies between cards and can
// only be obtained via the driver. The loader will set this so we can use it.
extern "C" [[gnu::visibility("protected")]] uint64_t
    [[clang::address_space(4)]] __llvm_libc_clock_freq = 0;

extern "C" uintptr_t __init_array_start[];
extern "C" uintptr_t __init_array_end[];
extern "C" uintptr_t __fini_array_start[];
extern "C" uintptr_t __fini_array_end[];

using InitCallback = void(int, char **, char **);
using FiniCallback = void(void);

static void call_init_array_callbacks(int argc, char **argv, char **env) {
  size_t init_array_size = __init_array_end - __init_array_start;
  for (size_t i = 0; i < init_array_size; ++i)
    reinterpret_cast<InitCallback *>(__init_array_start[i])(argc, argv, env);
}

static void call_fini_array_callbacks() {
  size_t fini_array_size = __fini_array_end - __fini_array_start;
  for (size_t i = fini_array_size; i > 0; --i)
    reinterpret_cast<FiniCallback *>(__fini_array_start[i - 1])();
}

} // namespace __llvm_libc

extern "C" [[gnu::visibility("protected"), clang::amdgpu_kernel]] void
_begin(int argc, char **argv, char **env, void *rpc_shared_buffer) {
  // We need to set up the RPC client first in case any of the constructors
  // require it.
  __llvm_libc::rpc::client.reset(__llvm_libc::rpc::MAX_PORT_COUNT,
                                 rpc_shared_buffer);

  // We want the fini array callbacks to be run after other atexit
  // callbacks are run. So, we register them before running the init
  // array callbacks as they can potentially register their own atexit
  // callbacks.
  __llvm_libc::atexit(&__llvm_libc::call_fini_array_callbacks);
  __llvm_libc::call_init_array_callbacks(argc, argv, env);
}

extern "C" [[gnu::visibility("protected"), clang::amdgpu_kernel]] void
_start(int argc, char **argv, char **envp, int *ret) {
  // Invoke the 'main' function with every active thread that the user launched
  // the _start kernel with.
  __atomic_fetch_or(ret, main(argc, argv, envp), __ATOMIC_RELAXED);
}

extern "C" [[gnu::visibility("protected"), clang::amdgpu_kernel]] void
_end(int retval) {
  // Only a single thread should call `exit` here, the rest should gracefully
  // return from the kernel. This is so only one thread calls the destructors
  // registred with 'atexit' above.
  __llvm_libc::exit(retval);
}
