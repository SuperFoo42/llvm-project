//===-- Implementation of rand --------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/stdlib/rand.h"
#include "src/__support/common.h"
#include "src/stdlib/rand_util.h"

namespace __llvm_libc {

// An implementation of the xorshift64star pseudo random number generator. This
// is a good general purpose generator for most non-cryptographics applications.
LLVM_LIBC_FUNCTION(int, rand, (void)) {
  unsigned long x = rand_next;
  x ^= x >> 12;
  x ^= x << 25;
  x ^= x >> 27;
  rand_next = x;
  return static_cast<int>((x * 0x2545F4914F6CDD1Dul) >> 32) & RAND_MAX;
}

} // namespace __llvm_libc
