; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+f -verify-machineinstrs < %s \
; RUN:   -target-abi=ilp32f | FileCheck -check-prefixes=CHECKIF,RV32IF %s
; RUN: llc -mtriple=riscv64 -mattr=+f -verify-machineinstrs < %s \
; RUN:   -target-abi=lp64f | FileCheck -check-prefixes=CHECKIF,RV64IF %s
; RUN: llc -mtriple=riscv32 -mattr=+zfinx -verify-machineinstrs < %s \
; RUN:   -target-abi=ilp32 | FileCheck -check-prefixes=CHECKIZFINX,RV32IZFINX %s
; RUN: llc -mtriple=riscv64 -mattr=+zfinx -verify-machineinstrs < %s \
; RUN:   -target-abi=lp64 | FileCheck -check-prefixes=CHECKIZFINX,RV64IZFINX %s

define dso_local float @flw(ptr %a) nounwind {
; CHECKIF-LABEL: flw:
; CHECKIF:       # %bb.0:
; CHECKIF-NEXT:    flw fa5, 0(a0)
; CHECKIF-NEXT:    flw fa4, 12(a0)
; CHECKIF-NEXT:    fadd.s fa0, fa5, fa4
; CHECKIF-NEXT:    ret
;
; CHECKIZFINX-LABEL: flw:
; CHECKIZFINX:       # %bb.0:
; CHECKIZFINX-NEXT:    lw a1, 0(a0)
; CHECKIZFINX-NEXT:    lw a0, 12(a0)
; CHECKIZFINX-NEXT:    fadd.s a0, a1, a0
; CHECKIZFINX-NEXT:    ret
  %1 = load float, ptr %a
  %2 = getelementptr float, ptr %a, i32 3
  %3 = load float, ptr %2
; Use both loaded values in an FP op to ensure an flw is used, even for the
; soft float ABI
  %4 = fadd float %1, %3
  ret float %4
}

define dso_local void @fsw(ptr %a, float %b, float %c) nounwind {
; Use %b and %c in an FP op to ensure floating point registers are used, even
; for the soft float ABI
; CHECKIF-LABEL: fsw:
; CHECKIF:       # %bb.0:
; CHECKIF-NEXT:    fadd.s fa5, fa0, fa1
; CHECKIF-NEXT:    fsw fa5, 0(a0)
; CHECKIF-NEXT:    fsw fa5, 32(a0)
; CHECKIF-NEXT:    ret
;
; CHECKIZFINX-LABEL: fsw:
; CHECKIZFINX:       # %bb.0:
; CHECKIZFINX-NEXT:    fadd.s a1, a1, a2
; CHECKIZFINX-NEXT:    sw a1, 0(a0)
; CHECKIZFINX-NEXT:    sw a1, 32(a0)
; CHECKIZFINX-NEXT:    ret
  %1 = fadd float %b, %c
  store float %1, ptr %a
  %2 = getelementptr float, ptr %a, i32 8
  store float %1, ptr %2
  ret void
}

; Check load and store to a global
@G = dso_local global float 0.0

define dso_local float @flw_fsw_global(float %a, float %b) nounwind {
; Use %a and %b in an FP op to ensure floating point registers are used, even
; for the soft float ABI
; CHECKIF-LABEL: flw_fsw_global:
; CHECKIF:       # %bb.0:
; CHECKIF-NEXT:    fadd.s fa0, fa0, fa1
; CHECKIF-NEXT:    lui a0, %hi(G)
; CHECKIF-NEXT:    flw fa5, %lo(G)(a0)
; CHECKIF-NEXT:    addi a1, a0, %lo(G)
; CHECKIF-NEXT:    fsw fa0, %lo(G)(a0)
; CHECKIF-NEXT:    flw fa5, 36(a1)
; CHECKIF-NEXT:    fsw fa0, 36(a1)
; CHECKIF-NEXT:    ret
;
; CHECKIZFINX-LABEL: flw_fsw_global:
; CHECKIZFINX:       # %bb.0:
; CHECKIZFINX-NEXT:    fadd.s a0, a0, a1
; CHECKIZFINX-NEXT:    lui a1, %hi(G)
; CHECKIZFINX-NEXT:    lw a2, %lo(G)(a1)
; CHECKIZFINX-NEXT:    addi a2, a1, %lo(G)
; CHECKIZFINX-NEXT:    sw a0, %lo(G)(a1)
; CHECKIZFINX-NEXT:    lw a1, 36(a2)
; CHECKIZFINX-NEXT:    sw a0, 36(a2)
; CHECKIZFINX-NEXT:    ret
  %1 = fadd float %a, %b
  %2 = load volatile float, ptr @G
  store float %1, ptr @G
  %3 = getelementptr float, ptr @G, i32 9
  %4 = load volatile float, ptr %3
  store float %1, ptr %3
  ret float %1
}

; Ensure that 1 is added to the high 20 bits if bit 11 of the low part is 1
define dso_local float @flw_fsw_constant(float %a) nounwind {
; RV32IF-LABEL: flw_fsw_constant:
; RV32IF:       # %bb.0:
; RV32IF-NEXT:    lui a0, 912092
; RV32IF-NEXT:    flw fa5, -273(a0)
; RV32IF-NEXT:    fadd.s fa0, fa0, fa5
; RV32IF-NEXT:    fsw fa0, -273(a0)
; RV32IF-NEXT:    ret
;
; RV64IF-LABEL: flw_fsw_constant:
; RV64IF:       # %bb.0:
; RV64IF-NEXT:    lui a0, 228023
; RV64IF-NEXT:    slli a0, a0, 2
; RV64IF-NEXT:    flw fa5, -273(a0)
; RV64IF-NEXT:    fadd.s fa0, fa0, fa5
; RV64IF-NEXT:    fsw fa0, -273(a0)
; RV64IF-NEXT:    ret
;
; RV32IZFINX-LABEL: flw_fsw_constant:
; RV32IZFINX:       # %bb.0:
; RV32IZFINX-NEXT:    lui a1, 912092
; RV32IZFINX-NEXT:    lw a2, -273(a1)
; RV32IZFINX-NEXT:    fadd.s a0, a0, a2
; RV32IZFINX-NEXT:    sw a0, -273(a1)
; RV32IZFINX-NEXT:    ret
;
; RV64IZFINX-LABEL: flw_fsw_constant:
; RV64IZFINX:       # %bb.0:
; RV64IZFINX-NEXT:    lui a1, 228023
; RV64IZFINX-NEXT:    slli a1, a1, 2
; RV64IZFINX-NEXT:    lw a2, -273(a1)
; RV64IZFINX-NEXT:    fadd.s a0, a0, a2
; RV64IZFINX-NEXT:    sw a0, -273(a1)
; RV64IZFINX-NEXT:    ret
  %1 = inttoptr i32 3735928559 to ptr
  %2 = load volatile float, ptr %1
  %3 = fadd float %a, %2
  store float %3, ptr %1
  ret float %3
}

declare void @notdead(ptr)

define dso_local float @flw_stack(float %a) nounwind {
; RV32IF-LABEL: flw_stack:
; RV32IF:       # %bb.0:
; RV32IF-NEXT:    addi sp, sp, -16
; RV32IF-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IF-NEXT:    fsw fs0, 8(sp) # 4-byte Folded Spill
; RV32IF-NEXT:    fmv.s fs0, fa0
; RV32IF-NEXT:    addi a0, sp, 4
; RV32IF-NEXT:    call notdead
; RV32IF-NEXT:    flw fa5, 4(sp)
; RV32IF-NEXT:    fadd.s fa0, fa5, fs0
; RV32IF-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IF-NEXT:    flw fs0, 8(sp) # 4-byte Folded Reload
; RV32IF-NEXT:    addi sp, sp, 16
; RV32IF-NEXT:    ret
;
; RV64IF-LABEL: flw_stack:
; RV64IF:       # %bb.0:
; RV64IF-NEXT:    addi sp, sp, -16
; RV64IF-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64IF-NEXT:    fsw fs0, 4(sp) # 4-byte Folded Spill
; RV64IF-NEXT:    fmv.s fs0, fa0
; RV64IF-NEXT:    mv a0, sp
; RV64IF-NEXT:    call notdead
; RV64IF-NEXT:    flw fa5, 0(sp)
; RV64IF-NEXT:    fadd.s fa0, fa5, fs0
; RV64IF-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64IF-NEXT:    flw fs0, 4(sp) # 4-byte Folded Reload
; RV64IF-NEXT:    addi sp, sp, 16
; RV64IF-NEXT:    ret
;
; RV32IZFINX-LABEL: flw_stack:
; RV32IZFINX:       # %bb.0:
; RV32IZFINX-NEXT:    addi sp, sp, -16
; RV32IZFINX-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IZFINX-NEXT:    sw s0, 8(sp) # 4-byte Folded Spill
; RV32IZFINX-NEXT:    mv s0, a0
; RV32IZFINX-NEXT:    addi a0, sp, 4
; RV32IZFINX-NEXT:    call notdead
; RV32IZFINX-NEXT:    lw a0, 4(sp)
; RV32IZFINX-NEXT:    fadd.s a0, a0, s0
; RV32IZFINX-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IZFINX-NEXT:    lw s0, 8(sp) # 4-byte Folded Reload
; RV32IZFINX-NEXT:    addi sp, sp, 16
; RV32IZFINX-NEXT:    ret
;
; RV64IZFINX-LABEL: flw_stack:
; RV64IZFINX:       # %bb.0:
; RV64IZFINX-NEXT:    addi sp, sp, -32
; RV64IZFINX-NEXT:    sd ra, 24(sp) # 8-byte Folded Spill
; RV64IZFINX-NEXT:    sd s0, 16(sp) # 8-byte Folded Spill
; RV64IZFINX-NEXT:    mv s0, a0
; RV64IZFINX-NEXT:    addi a0, sp, 12
; RV64IZFINX-NEXT:    call notdead
; RV64IZFINX-NEXT:    lw a0, 12(sp)
; RV64IZFINX-NEXT:    fadd.s a0, a0, s0
; RV64IZFINX-NEXT:    ld ra, 24(sp) # 8-byte Folded Reload
; RV64IZFINX-NEXT:    ld s0, 16(sp) # 8-byte Folded Reload
; RV64IZFINX-NEXT:    addi sp, sp, 32
; RV64IZFINX-NEXT:    ret
  %1 = alloca float, align 4
  call void @notdead(ptr %1)
  %2 = load float, ptr %1
  %3 = fadd float %2, %a ; force load in to FPR32
  ret float %3
}

define dso_local void @fsw_stack(float %a, float %b) nounwind {
; RV32IF-LABEL: fsw_stack:
; RV32IF:       # %bb.0:
; RV32IF-NEXT:    addi sp, sp, -16
; RV32IF-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IF-NEXT:    fadd.s fa5, fa0, fa1
; RV32IF-NEXT:    fsw fa5, 8(sp)
; RV32IF-NEXT:    addi a0, sp, 8
; RV32IF-NEXT:    call notdead
; RV32IF-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IF-NEXT:    addi sp, sp, 16
; RV32IF-NEXT:    ret
;
; RV64IF-LABEL: fsw_stack:
; RV64IF:       # %bb.0:
; RV64IF-NEXT:    addi sp, sp, -16
; RV64IF-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64IF-NEXT:    fadd.s fa5, fa0, fa1
; RV64IF-NEXT:    fsw fa5, 4(sp)
; RV64IF-NEXT:    addi a0, sp, 4
; RV64IF-NEXT:    call notdead
; RV64IF-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64IF-NEXT:    addi sp, sp, 16
; RV64IF-NEXT:    ret
;
; RV32IZFINX-LABEL: fsw_stack:
; RV32IZFINX:       # %bb.0:
; RV32IZFINX-NEXT:    addi sp, sp, -16
; RV32IZFINX-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IZFINX-NEXT:    fadd.s a0, a0, a1
; RV32IZFINX-NEXT:    sw a0, 8(sp)
; RV32IZFINX-NEXT:    addi a0, sp, 8
; RV32IZFINX-NEXT:    call notdead
; RV32IZFINX-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IZFINX-NEXT:    addi sp, sp, 16
; RV32IZFINX-NEXT:    ret
;
; RV64IZFINX-LABEL: fsw_stack:
; RV64IZFINX:       # %bb.0:
; RV64IZFINX-NEXT:    addi sp, sp, -16
; RV64IZFINX-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64IZFINX-NEXT:    fadd.s a0, a0, a1
; RV64IZFINX-NEXT:    sw a0, 4(sp)
; RV64IZFINX-NEXT:    addi a0, sp, 4
; RV64IZFINX-NEXT:    call notdead
; RV64IZFINX-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64IZFINX-NEXT:    addi sp, sp, 16
; RV64IZFINX-NEXT:    ret
  %1 = fadd float %a, %b ; force store from FPR32
  %2 = alloca float, align 4
  store float %1, ptr %2
  call void @notdead(ptr %2)
  ret void
}
