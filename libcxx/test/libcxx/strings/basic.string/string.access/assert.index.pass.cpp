//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <string>

// Index string out of bounds.

// REQUIRES: has-unix-headers
// UNSUPPORTED: c++03
// UNSUPPORTED: libcpp-hardening-mode=none
// XFAIL: availability-verbose_abort-missing

#include <string>
#include <cassert>

#include "check_assertion.h"
#include "min_allocator.h"

int main(int, char**) {
  {
    typedef std::string S;
    S s;
    assert(s[0] == 0);
    TEST_LIBCPP_ASSERT_FAILURE(s[1], "string index out of bounds");
  }

  {
    typedef std::basic_string<char, std::char_traits<char>, min_allocator<char> > S;
    S s;
    assert(s[0] == 0);
    TEST_LIBCPP_ASSERT_FAILURE(s[1], "string index out of bounds");
  }

  return 0;
}
