// RUN: %clang %cflags -o %t %s
// RUN: llvm-bolt --print-cfg --print-only=_start -o %t.null %t \
// RUN:    | FileCheck %s

  .data
  .globl d
  .p2align 3
d:
  .dword 0

  .text
  .globl _start
  .p2align 1
// CHECK: Binary Function "_start" after building cfg {
_start:
  nop // Here to not make the _start and .Ltmp0 symbols coincide
// CHECK: .Ltmp0
// CHECK: auipc t0, %pcrel_hi(d)
// CHECK-NEXT: ld t0, %pcrel_lo(.Ltmp0)(t0)
  ld t0, d
// CHECK: .Ltmp1
// CHECK: auipc t1, %pcrel_hi(d)
// CHECK-NEXT: sd t0, %pcrel_lo(.Ltmp1)(t1)
  sd t0, d, t1
  ret
  .size _start, .-_start
