// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP_EXPERIMENTAL___SIMD_SCALAR_H
#define _LIBCPP_EXPERIMENTAL___SIMD_SCALAR_H

#include <cstddef>
#include <experimental/__config>
#include <experimental/__simd/declaration.h>
#include <experimental/__simd/traits.h>

#if _LIBCPP_STD_VER >= 17 && defined(_LIBCPP_ENABLE_EXPERIMENTAL)

_LIBCPP_BEGIN_NAMESPACE_EXPERIMENTAL
inline namespace parallelism_v2 {
namespace simd_abi {
struct __scalar {
  static constexpr size_t __simd_size = 1;
};
} // namespace simd_abi

template <>
inline constexpr bool is_abi_tag_v<simd_abi::__scalar> = true;

template <class _Tp>
struct __simd_storage<_Tp, simd_abi::__scalar> {
  _Tp __data;

  _Tp __get([[maybe_unused]] size_t __idx) const noexcept {
    _LIBCPP_ASSERT_UNCATEGORIZED(__idx == 0, "Index is out of bounds");
    return __data;
  }
  void __set([[maybe_unused]] size_t __idx, _Tp __v) noexcept {
    _LIBCPP_ASSERT_UNCATEGORIZED(__idx == 0, "Index is out of bounds");
    __data = __v;
  }
};

template <class _Tp>
struct __mask_storage<_Tp, simd_abi::__scalar> : __simd_storage<bool, simd_abi::__scalar> {};

template <class _Tp>
struct __simd_operations<_Tp, simd_abi::__scalar> {
  using _SimdStorage = __simd_storage<_Tp, simd_abi::__scalar>;
  using _MaskStorage = __mask_storage<_Tp, simd_abi::__scalar>;

  static _SimdStorage __broadcast(_Tp __v) noexcept { return {__v}; }
};

template <class _Tp>
struct __mask_operations<_Tp, simd_abi::__scalar> {
  using _MaskStorage = __mask_storage<_Tp, simd_abi::__scalar>;

  static _MaskStorage __broadcast(bool __v) noexcept { return {__v}; }
};

} // namespace parallelism_v2
_LIBCPP_END_NAMESPACE_EXPERIMENTAL

#endif // _LIBCPP_STD_VER >= 17 && defined(_LIBCPP_ENABLE_EXPERIMENTAL)
#endif // _LIBCPP_EXPERIMENTAL___SIMD_SCALAR_H
