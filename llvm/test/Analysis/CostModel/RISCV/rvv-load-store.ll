; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt -passes="print<cost-model>" 2>&1 -disable-output -mtriple=riscv64 -mattr=+v,+f,+d,+zfh,+zvfh -riscv-v-vector-bits-min=128 -riscv-v-fixed-length-vector-lmul-max=1 < %s | FileCheck %s
; Check that we don't crash querying costs when vectors are not enabled.
; RUN: opt -passes="print<cost-model>" 2>&1 -disable-output -mtriple=riscv64

define void @load(ptr %p) {
; CHECK-LABEL: 'load'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = load i8, ptr %p, align 1
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %2 = load <1 x i8>, ptr %p, align 1
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %3 = load <2 x i8>, ptr %p, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %4 = load <4 x i8>, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %5 = load <8 x i8>, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %6 = load <16 x i8>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %7 = load <32 x i8>, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %8 = load <vscale x 1 x i8>, ptr %p, align 1
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %9 = load <vscale x 2 x i8>, ptr %p, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %10 = load <vscale x 4 x i8>, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %11 = load <vscale x 8 x i8>, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %12 = load <vscale x 16 x i8>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %13 = load <vscale x 32 x i8>, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %14 = load i16, ptr %p, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %15 = load <1 x i16>, ptr %p, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %16 = load <2 x i16>, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %17 = load <4 x i16>, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %18 = load <8 x i16>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %19 = load <16 x i16>, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %20 = load <32 x i16>, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %21 = load <vscale x 1 x i16>, ptr %p, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %22 = load <vscale x 2 x i16>, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %23 = load <vscale x 4 x i16>, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %24 = load <vscale x 8 x i16>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %25 = load <vscale x 16 x i16>, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: %26 = load <vscale x 32 x i16>, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %27 = load i32, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %28 = load <1 x i32>, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %29 = load <2 x i32>, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %30 = load <4 x i32>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %31 = load <8 x i32>, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %32 = load <16 x i32>, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: %33 = load <32 x i32>, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %34 = load <vscale x 1 x i32>, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %35 = load <vscale x 2 x i32>, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %36 = load <vscale x 4 x i32>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %37 = load <vscale x 8 x i32>, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: %38 = load <vscale x 16 x i32>, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 16 for instruction: %39 = load <vscale x 32 x i32>, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %40 = load i64, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %41 = load <1 x i64>, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %42 = load <2 x i64>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %43 = load <4 x i64>, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %44 = load <8 x i64>, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: %45 = load <16 x i64>, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 16 for instruction: %46 = load <32 x i64>, ptr %p, align 256
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %47 = load <vscale x 1 x i64>, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %48 = load <vscale x 2 x i64>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %49 = load <vscale x 4 x i64>, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: %50 = load <vscale x 8 x i64>, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 16 for instruction: %51 = load <vscale x 16 x i64>, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 32 for instruction: %52 = load <vscale x 32 x i64>, ptr %p, align 256
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %53 = load ptr, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %54 = load <1 x ptr>, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %55 = load <2 x ptr>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %56 = load <4 x ptr>, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %57 = load <8 x ptr>, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: %58 = load <16 x ptr>, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 16 for instruction: %59 = load <32 x ptr>, ptr %p, align 256
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %60 = load <vscale x 1 x ptr>, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %61 = load <vscale x 2 x ptr>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %62 = load <vscale x 4 x ptr>, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: %63 = load <vscale x 8 x ptr>, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 16 for instruction: %64 = load <vscale x 16 x ptr>, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 32 for instruction: %65 = load <vscale x 32 x ptr>, ptr %p, align 256
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret void
;
  load i8, ptr %p
  load <1 x i8>, ptr %p
  load <2 x i8>, ptr %p
  load <4 x i8>, ptr %p
  load <8 x i8>, ptr %p
  load <16 x i8>, ptr %p
  load <32 x i8>, ptr %p
  load <vscale x 1 x i8>, ptr %p
  load <vscale x 2 x i8>, ptr %p
  load <vscale x 4 x i8>, ptr %p
  load <vscale x 8 x i8>, ptr %p
  load <vscale x 16 x i8>, ptr %p
  load <vscale x 32 x i8>, ptr %p

  load i16, ptr %p
  load <1 x i16>, ptr %p
  load <2 x i16>, ptr %p
  load <4 x i16>, ptr %p
  load <8 x i16>, ptr %p
  load <16 x i16>, ptr %p
  load <32 x i16>, ptr %p
  load <vscale x 1 x i16>, ptr %p
  load <vscale x 2 x i16>, ptr %p
  load <vscale x 4 x i16>, ptr %p
  load <vscale x 8 x i16>, ptr %p
  load <vscale x 16 x i16>, ptr %p
  load <vscale x 32 x i16>, ptr %p


  load i32, ptr %p
  load <1 x i32>, ptr %p
  load <2 x i32>, ptr %p
  load <4 x i32>, ptr %p
  load <8 x i32>, ptr %p
  load <16 x i32>, ptr %p
  load <32 x i32>, ptr %p
  load <vscale x 1 x i32>, ptr %p
  load <vscale x 2 x i32>, ptr %p
  load <vscale x 4 x i32>, ptr %p
  load <vscale x 8 x i32>, ptr %p
  load <vscale x 16 x i32>, ptr %p
  load <vscale x 32 x i32>, ptr %p

  load i64, ptr %p
  load <1 x i64>, ptr %p
  load <2 x i64>, ptr %p
  load <4 x i64>, ptr %p
  load <8 x i64>, ptr %p
  load <16 x i64>, ptr %p
  load <32 x i64>, ptr %p
  load <vscale x 1 x i64>, ptr %p
  load <vscale x 2 x i64>, ptr %p
  load <vscale x 4 x i64>, ptr %p
  load <vscale x 8 x i64>, ptr %p
  load <vscale x 16 x i64>, ptr %p
  load <vscale x 32 x i64>, ptr %p

  load ptr, ptr %p
  load <1 x ptr>, ptr %p
  load <2 x ptr>, ptr %p
  load <4 x ptr>, ptr %p
  load <8 x ptr>, ptr %p
  load <16 x ptr>, ptr %p
  load <32 x ptr>, ptr %p
  load <vscale x 1 x ptr>, ptr %p
  load <vscale x 2 x ptr>, ptr %p
  load <vscale x 4 x ptr>, ptr %p
  load <vscale x 8 x ptr>, ptr %p
  load <vscale x 16 x ptr>, ptr %p
  load <vscale x 32 x ptr>, ptr %p

  ret void
}

define void @store(ptr %p) {
; CHECK-LABEL: 'store'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store i8 undef, ptr %p, align 1
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <1 x i8> undef, ptr %p, align 1
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <2 x i8> undef, ptr %p, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <4 x i8> undef, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <8 x i8> undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <16 x i8> undef, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <32 x i8> undef, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <vscale x 1 x i8> undef, ptr %p, align 1
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <vscale x 2 x i8> undef, ptr %p, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <vscale x 4 x i8> undef, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <vscale x 8 x i8> undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <vscale x 16 x i8> undef, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <vscale x 32 x i8> undef, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store i16 undef, ptr %p, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <1 x i16> undef, ptr %p, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <2 x i16> undef, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <4 x i16> undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <8 x i16> undef, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <16 x i16> undef, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <32 x i16> undef, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <vscale x 1 x i16> undef, ptr %p, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <vscale x 2 x i16> undef, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <vscale x 4 x i16> undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <vscale x 8 x i16> undef, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <vscale x 16 x i16> undef, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: store <vscale x 32 x i16> undef, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store i32 undef, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <1 x i32> undef, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <2 x i32> undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <4 x i32> undef, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <8 x i32> undef, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <16 x i32> undef, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: store <32 x i32> undef, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <vscale x 1 x i32> undef, ptr %p, align 4
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <vscale x 2 x i32> undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <vscale x 4 x i32> undef, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <vscale x 8 x i32> undef, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: store <vscale x 16 x i32> undef, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 16 for instruction: store <vscale x 32 x i32> undef, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store i64 undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <1 x i64> undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <2 x i64> undef, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <4 x i64> undef, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <8 x i64> undef, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: store <16 x i64> undef, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 16 for instruction: store <32 x i64> undef, ptr %p, align 256
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <vscale x 1 x i64> undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <vscale x 2 x i64> undef, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <vscale x 4 x i64> undef, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: store <vscale x 8 x i64> undef, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 16 for instruction: store <vscale x 16 x i64> undef, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 32 for instruction: store <vscale x 32 x i64> undef, ptr %p, align 256
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store ptr undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <1 x ptr> undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <2 x ptr> undef, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <4 x ptr> undef, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <8 x ptr> undef, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: store <16 x ptr> undef, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 16 for instruction: store <32 x ptr> undef, ptr %p, align 256
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <vscale x 1 x ptr> undef, ptr %p, align 8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <vscale x 2 x ptr> undef, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <vscale x 4 x ptr> undef, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: store <vscale x 8 x ptr> undef, ptr %p, align 64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 16 for instruction: store <vscale x 16 x ptr> undef, ptr %p, align 128
; CHECK-NEXT:  Cost Model: Found an estimated cost of 32 for instruction: store <vscale x 32 x ptr> undef, ptr %p, align 256
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret void
;
  store i8 undef, ptr %p
  store <1 x i8> undef, ptr %p
  store <2 x i8> undef, ptr %p
  store <4 x i8> undef, ptr %p
  store <8 x i8> undef, ptr %p
  store <16 x i8> undef, ptr %p
  store <32 x i8> undef, ptr %p
  store <vscale x 1 x i8> undef, ptr %p
  store <vscale x 2 x i8> undef, ptr %p
  store <vscale x 4 x i8> undef, ptr %p
  store <vscale x 8 x i8> undef, ptr %p
  store <vscale x 16 x i8> undef, ptr %p
  store <vscale x 32 x i8> undef, ptr %p

  store i16 undef, ptr %p
  store <1 x i16> undef, ptr %p
  store <2 x i16> undef, ptr %p
  store <4 x i16> undef, ptr %p
  store <8 x i16> undef, ptr %p
  store <16 x i16> undef, ptr %p
  store <32 x i16> undef, ptr %p
  store <vscale x 1 x i16> undef, ptr %p
  store <vscale x 2 x i16> undef, ptr %p
  store <vscale x 4 x i16> undef, ptr %p
  store <vscale x 8 x i16> undef, ptr %p
  store <vscale x 16 x i16> undef, ptr %p
  store <vscale x 32 x i16> undef, ptr %p


  store i32 undef, ptr %p
  store <1 x i32> undef, ptr %p
  store <2 x i32> undef, ptr %p
  store <4 x i32> undef, ptr %p
  store <8 x i32> undef, ptr %p
  store <16 x i32> undef, ptr %p
  store <32 x i32> undef, ptr %p
  store <vscale x 1 x i32> undef, ptr %p
  store <vscale x 2 x i32> undef, ptr %p
  store <vscale x 4 x i32> undef, ptr %p
  store <vscale x 8 x i32> undef, ptr %p
  store <vscale x 16 x i32> undef, ptr %p
  store <vscale x 32 x i32> undef, ptr %p

  store i64 undef, ptr %p
  store <1 x i64> undef, ptr %p
  store <2 x i64> undef, ptr %p
  store <4 x i64> undef, ptr %p
  store <8 x i64> undef, ptr %p
  store <16 x i64> undef, ptr %p
  store <32 x i64> undef, ptr %p
  store <vscale x 1 x i64> undef, ptr %p
  store <vscale x 2 x i64> undef, ptr %p
  store <vscale x 4 x i64> undef, ptr %p
  store <vscale x 8 x i64> undef, ptr %p
  store <vscale x 16 x i64> undef, ptr %p
  store <vscale x 32 x i64> undef, ptr %p

  store ptr undef, ptr %p
  store <1 x ptr> undef, ptr %p
  store <2 x ptr> undef, ptr %p
  store <4 x ptr> undef, ptr %p
  store <8 x ptr> undef, ptr %p
  store <16 x ptr> undef, ptr %p
  store <32 x ptr> undef, ptr %p
  store <vscale x 1 x ptr> undef, ptr %p
  store <vscale x 2 x ptr> undef, ptr %p
  store <vscale x 4 x ptr> undef, ptr %p
  store <vscale x 8 x ptr> undef, ptr %p
  store <vscale x 16 x ptr> undef, ptr %p
  store <vscale x 32 x ptr> undef, ptr %p

  ret void
}

; For constants, have to account for cost of materializing the constant itself
; This test exercises a few interesting constant patterns at VLEN=128
define void @store_of_constant(ptr %p) {
; CHECK-LABEL: 'store_of_constant'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <4 x i32> poison, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <4 x i32> undef, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: store <4 x i32> zeroinitializer, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <4 x i64> zeroinitializer, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <4 x i32> <i32 1, i32 1, i32 1, i32 1>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: store <4 x i64> <i64 1, i64 1, i64 1, i64 1>, ptr %p, align 32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: store <4 x i32> <i32 4096, i32 4096, i32 4096, i32 4096>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <4 x i32> <i32 1, i32 1, i32 2, i32 1>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <4 x i32> <i32 2, i32 1, i32 1, i32 1>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <4 x i32> <i32 0, i32 1, i32 2, i32 3>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <4 x i32> <i32 1, i32 2, i32 3, i32 4>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <4 x i32> <i32 -1, i32 -2, i32 -3, i32 -4>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <4 x i32> <i32 2, i32 4, i32 6, i32 8>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <4 x i32> <i32 -1, i32 0, i32 2, i32 1>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: store <4 x i32> <i32 256, i32 4096, i32 57, i32 1>, ptr %p, align 16
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret void
;

  ; poison and undef
  store <4 x i32> poison, ptr %p
  store <4 x i32> undef, ptr %p

  ; Various splats
  store <4 x i32> zeroinitializer, ptr %p
  store <4 x i64> zeroinitializer, ptr %p
  store <4 x i32> <i32 1, i32 1, i32 1, i32 1>, ptr %p
  store <4 x i64> <i64 1, i64 1, i64 1, i64 1>, ptr %p
  store <4 x i32> <i32 4096, i32 4096, i32 4096, i32 4096>, ptr %p

  ; Nearly splats
  store <4 x i32> <i32 1, i32 1, i32 2, i32 1>, ptr %p
  store <4 x i32> <i32 2, i32 1, i32 1, i32 1>, ptr %p

  ; Step vector functions
  store <4 x i32> <i32 0, i32 1, i32 2, i32 3>, ptr %p
  store <4 x i32> <i32 1, i32 2, i32 3, i32 4>, ptr %p
  store <4 x i32> <i32 -1, i32 -2, i32 -3, i32 -4>, ptr %p
  store <4 x i32> <i32 2, i32 4, i32 6, i32 8>, ptr %p

  ; General case 128 bit constants
  store <4 x i32> <i32 -1, i32 0, i32 2, i32 1>, ptr %p
  store <4 x i32> <i32 256, i32 4096, i32 57, i32 1>, ptr %p

  ret void
}
