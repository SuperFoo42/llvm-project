//===-- Nearest integer floating-point operations ---------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_SUPPORT_FPUTIL_NEAREST_INTEGER_OPERATIONS_H
#define LLVM_LIBC_SRC_SUPPORT_FPUTIL_NEAREST_INTEGER_OPERATIONS_H

#include "FEnvImpl.h"
#include "FPBits.h"
#include "rounding_mode.h"

#include "src/__support/CPP/type_traits.h"
#include "src/__support/common.h"

#include <math.h>

namespace __llvm_libc {
namespace fputil {

template <typename T, cpp::enable_if_t<cpp::is_floating_point_v<T>, int> = 0>
LIBC_INLINE T trunc(T x) {
  FPBits<T> bits(x);

  // If x is infinity or NaN, return it.
  // If it is zero also we should return it as is, but the logic
  // later in this function takes care of it. But not doing a zero
  // check, we improve the run time of non-zero values.
  if (bits.is_inf_or_nan())
    return x;

  int exponent = bits.get_exponent();

  // If the exponent is greater than the most negative mantissa
  // exponent, then x is already an integer.
  if (exponent >= static_cast<int>(FPBits<T>::FRACTION_LEN))
    return x;

  // If the exponent is such that abs(x) is less than 1, then return 0.
  if (exponent <= -1) {
    if (bits.get_sign())
      return T(-0.0);
    else
      return T(0.0);
  }

  int trim_size = FPBits<T>::FRACTION_LEN - exponent;
  bits.set_mantissa((bits.get_mantissa() >> trim_size) << trim_size);
  return T(bits);
}

template <typename T, cpp::enable_if_t<cpp::is_floating_point_v<T>, int> = 0>
LIBC_INLINE T ceil(T x) {
  FPBits<T> bits(x);

  // If x is infinity NaN or zero, return it.
  if (bits.is_inf_or_nan() || bits.is_zero())
    return x;

  bool is_neg = bits.get_sign();
  int exponent = bits.get_exponent();

  // If the exponent is greater than the most negative mantissa
  // exponent, then x is already an integer.
  if (exponent >= static_cast<int>(FPBits<T>::FRACTION_LEN))
    return x;

  if (exponent <= -1) {
    if (is_neg)
      return T(-0.0);
    else
      return T(1.0);
  }

  uint32_t trim_size = FPBits<T>::FRACTION_LEN - exponent;
  bits.set_mantissa((bits.get_mantissa() >> trim_size) << trim_size);
  T trunc_value = T(bits);

  // If x is already an integer, return it.
  if (trunc_value == x)
    return x;

  // If x is negative, the ceil operation is equivalent to the trunc operation.
  if (is_neg)
    return trunc_value;

  return trunc_value + T(1.0);
}

template <typename T, cpp::enable_if_t<cpp::is_floating_point_v<T>, int> = 0>
LIBC_INLINE T floor(T x) {
  FPBits<T> bits(x);
  if (bits.get_sign()) {
    return -ceil(-x);
  } else {
    return trunc(x);
  }
}

template <typename T, cpp::enable_if_t<cpp::is_floating_point_v<T>, int> = 0>
LIBC_INLINE T round(T x) {
  using StorageType = typename FPBits<T>::StorageType;
  FPBits<T> bits(x);

  // If x is infinity NaN or zero, return it.
  if (bits.is_inf_or_nan() || bits.is_zero())
    return x;

  bool is_neg = bits.get_sign();
  int exponent = bits.get_exponent();

  // If the exponent is greater than the most negative mantissa
  // exponent, then x is already an integer.
  if (exponent >= static_cast<int>(FPBits<T>::FRACTION_LEN))
    return x;

  if (exponent == -1) {
    // Absolute value of x is greater than equal to 0.5 but less than 1.
    if (is_neg)
      return T(-1.0);
    else
      return T(1.0);
  }

  if (exponent <= -2) {
    // Absolute value of x is less than 0.5.
    if (is_neg)
      return T(-0.0);
    else
      return T(0.0);
  }

  uint32_t trim_size = FPBits<T>::FRACTION_LEN - exponent;
  bool half_bit_set =
      bool(bits.get_mantissa() & (StorageType(1) << (trim_size - 1)));
  bits.set_mantissa((bits.get_mantissa() >> trim_size) << trim_size);
  T trunc_value = T(bits);

  // If x is already an integer, return it.
  if (trunc_value == x)
    return x;

  if (!half_bit_set) {
    // Franctional part is less than 0.5 so round value is the
    // same as the trunc value.
    return trunc_value;
  } else {
    return is_neg ? trunc_value - T(1.0) : trunc_value + T(1.0);
  }
}

template <typename T, cpp::enable_if_t<cpp::is_floating_point_v<T>, int> = 0>
LIBC_INLINE T round_using_current_rounding_mode(T x) {
  using StorageType = typename FPBits<T>::StorageType;
  FPBits<T> bits(x);

  // If x is infinity NaN or zero, return it.
  if (bits.is_inf_or_nan() || bits.is_zero())
    return x;

  bool is_neg = bits.get_sign();
  int exponent = bits.get_exponent();
  int rounding_mode = quick_get_round();

  // If the exponent is greater than the most negative mantissa
  // exponent, then x is already an integer.
  if (exponent >= static_cast<int>(FPBits<T>::FRACTION_LEN))
    return x;

  if (exponent <= -1) {
    switch (rounding_mode) {
    case FE_DOWNWARD:
      return is_neg ? T(-1.0) : T(0.0);
    case FE_UPWARD:
      return is_neg ? T(-0.0) : T(1.0);
    case FE_TOWARDZERO:
      return is_neg ? T(-0.0) : T(0.0);
    case FE_TONEAREST:
      if (exponent <= -2 || bits.get_mantissa() == 0)
        return is_neg ? T(-0.0) : T(0.0); // abs(x) <= 0.5
      else
        return is_neg ? T(-1.0) : T(1.0); // abs(x) > 0.5
    default:
      __builtin_unreachable();
    }
  }

  uint32_t trim_size = FPBits<T>::FRACTION_LEN - exponent;
  FPBits<T> new_bits = bits;
  new_bits.set_mantissa((bits.get_mantissa() >> trim_size) << trim_size);
  T trunc_value = T(new_bits);

  // If x is already an integer, return it.
  if (trunc_value == x)
    return x;

  StorageType trim_value =
      bits.get_mantissa() & ((StorageType(1) << trim_size) - 1);
  StorageType half_value = (StorageType(1) << (trim_size - 1));
  // If exponent is 0, trimSize will be equal to the mantissa width, and
  // truncIsOdd` will not be correct. So, we handle it as a special case
  // below.
  StorageType trunc_is_odd =
      new_bits.get_mantissa() & (StorageType(1) << trim_size);

  switch (rounding_mode) {
  case FE_DOWNWARD:
    return is_neg ? trunc_value - T(1.0) : trunc_value;
  case FE_UPWARD:
    return is_neg ? trunc_value : trunc_value + T(1.0);
  case FE_TOWARDZERO:
    return trunc_value;
  case FE_TONEAREST:
    if (trim_value > half_value) {
      return is_neg ? trunc_value - T(1.0) : trunc_value + T(1.0);
    } else if (trim_value == half_value) {
      if (exponent == 0)
        return is_neg ? T(-2.0) : T(2.0);
      if (trunc_is_odd)
        return is_neg ? trunc_value - T(1.0) : trunc_value + T(1.0);
      else
        return trunc_value;
    } else {
      return trunc_value;
    }
  default:
    __builtin_unreachable();
  }
}

namespace internal {

template <typename F, typename I,
          cpp::enable_if_t<cpp::is_floating_point_v<F> && cpp::is_integral_v<I>,
                           int> = 0>
LIBC_INLINE I rounded_float_to_signed_integer(F x) {
  constexpr I INTEGER_MIN = (I(1) << (sizeof(I) * 8 - 1));
  constexpr I INTEGER_MAX = -(INTEGER_MIN + 1);
  FPBits<F> bits(x);
  auto set_domain_error_and_raise_invalid = []() {
    set_errno_if_required(EDOM);
    raise_except_if_required(FE_INVALID);
  };

  if (bits.is_inf_or_nan()) {
    set_domain_error_and_raise_invalid();
    return bits.get_sign() ? INTEGER_MIN : INTEGER_MAX;
  }

  int exponent = bits.get_exponent();
  constexpr int EXPONENT_LIMIT = sizeof(I) * 8 - 1;
  if (exponent > EXPONENT_LIMIT) {
    set_domain_error_and_raise_invalid();
    return bits.get_sign() ? INTEGER_MIN : INTEGER_MAX;
  } else if (exponent == EXPONENT_LIMIT) {
    if (bits.get_sign() == 0 || bits.get_mantissa() != 0) {
      set_domain_error_and_raise_invalid();
      return bits.get_sign() ? INTEGER_MIN : INTEGER_MAX;
    }
    // If the control reaches here, then it means that the rounded
    // value is the most negative number for the signed integer type I.
  }

  // For all other cases, if `x` can fit in the integer type `I`,
  // we just return `x`. static_cast will convert the floating
  // point value to the exact integer value.
  return static_cast<I>(x);
}

} // namespace internal

template <typename F, typename I,
          cpp::enable_if_t<cpp::is_floating_point_v<F> && cpp::is_integral_v<I>,
                           int> = 0>
LIBC_INLINE I round_to_signed_integer(F x) {
  return internal::rounded_float_to_signed_integer<F, I>(round(x));
}

template <typename F, typename I,
          cpp::enable_if_t<cpp::is_floating_point_v<F> && cpp::is_integral_v<I>,
                           int> = 0>
LIBC_INLINE I round_to_signed_integer_using_current_rounding_mode(F x) {
  return internal::rounded_float_to_signed_integer<F, I>(
      round_using_current_rounding_mode(x));
}

} // namespace fputil
} // namespace __llvm_libc

#endif // LLVM_LIBC_SRC_SUPPORT_FPUTIL_NEAREST_INTEGER_OPERATIONS_H
