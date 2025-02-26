//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <string>

// Call front() on empty const container.

// REQUIRES: has-unix-headers
// UNSUPPORTED: c++03
// UNSUPPORTED: libcpp-hardening-mode=none
// XFAIL: availability-verbose_abort-missing

#include <string>

#include "check_assertion.h"
#include "min_allocator.h"

int main(int, char**) {
  {
    typedef std::string S;
    const S s;
    TEST_LIBCPP_ASSERT_FAILURE(s.front(), "string::front(): string is empty");
  }

  {
    typedef std::basic_string<char, std::char_traits<char>, min_allocator<char> > S;
    const S s;
    TEST_LIBCPP_ASSERT_FAILURE(s.front(), "string::front(): string is empty");
  }

  return 0;
}
