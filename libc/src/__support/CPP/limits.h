//===-- A self contained equivalent of std::limits --------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_SUPPORT_CPP_LIMITS_H
#define LLVM_LIBC_SRC_SUPPORT_CPP_LIMITS_H

#include "src/__support/CPP/type_traits/is_integral.h"
#include "src/__support/CPP/type_traits/is_signed.h"
#include "src/__support/macros/attributes.h" // LIBC_INLINE

#include <limits.h> // CHAR_BIT

namespace __llvm_libc {
namespace cpp {

// Some older gcc distributions don't define these for 32 bit targets.
#ifndef LLONG_MAX
constexpr size_t LLONG_BIT_WIDTH = sizeof(long long) * 8;
constexpr long long LLONG_MAX = ~0LL ^ (1LL << LLONG_BIT_WIDTH - 1);
constexpr long long LLONG_MIN = 1LL << LLONG_BIT_WIDTH - 1;
constexpr unsigned long long ULLONG_MAX = ~0ULL;
#endif

namespace internal {

template <typename T, T min_value, T max_value> struct integer_impl {
  static_assert(cpp::is_integral_v<T>);
  LIBC_INLINE static constexpr T max() { return max_value; }
  LIBC_INLINE static constexpr T min() { return min_value; }
  LIBC_INLINE_VAR static constexpr int digits =
      CHAR_BIT * sizeof(T) - cpp::is_signed_v<T>;
};

} // namespace internal

template <class T> struct numeric_limits {};

// TODO: Add numeric_limits specializations as needed for new types.
template <>
struct numeric_limits<short>
    : public internal::integer_impl<short, SHRT_MIN, SHRT_MAX> {};

template <>
struct numeric_limits<unsigned short>
    : public internal::integer_impl<unsigned short, 0, USHRT_MAX> {};

template <>
struct numeric_limits<int>
    : public internal::integer_impl<int, INT_MIN, INT_MAX> {};

template <>
struct numeric_limits<unsigned int>
    : public internal::integer_impl<unsigned int, 0, UINT_MAX> {};

template <>
struct numeric_limits<long>
    : public internal::integer_impl<long, LONG_MIN, LONG_MAX> {};

template <>
struct numeric_limits<unsigned long>
    : public internal::integer_impl<unsigned long, 0, ULONG_MAX> {};

template <>
struct numeric_limits<long long>
    : public internal::integer_impl<long long, LLONG_MIN, LLONG_MAX> {};

template <>
struct numeric_limits<unsigned long long>
    : public internal::integer_impl<unsigned long long, 0, ULLONG_MAX> {};

template <>
struct numeric_limits<char>
    : public internal::integer_impl<char, CHAR_MIN, CHAR_MAX> {};

template <>
struct numeric_limits<signed char>
    : public internal::integer_impl<signed char, SCHAR_MIN, SCHAR_MAX> {};

template <>
struct numeric_limits<unsigned char>
    : public internal::integer_impl<unsigned char, 0, UCHAR_MAX> {};

#ifdef __SIZEOF_INT128__
// On platform where UInt128 resolves to __uint128_t, this specialization
// provides the limits of UInt128.
template <>
struct numeric_limits<__uint128_t>
    : public internal::integer_impl<__uint128_t, 0, ~__uint128_t(0)> {};
#endif

} // namespace cpp
} // namespace __llvm_libc

#endif // LLVM_LIBC_SRC_SUPPORT_CPP_LIMITS_H
