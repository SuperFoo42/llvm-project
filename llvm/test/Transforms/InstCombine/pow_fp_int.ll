; RUN: opt -mtriple unknown -passes=instcombine -S < %s | FileCheck %s
target datalayout = "e"

; PR42190
; Can't generate test checks due to PR42740.

define double @pow_sitofp_const_base_fast(i32 %x) {
; CHECK-LABEL: @pow_sitofp_const_base_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call afn float @llvm.powi.f32.i32(float 7.000000e+00, i32 [[X:%.*]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[TMP1]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = sitofp i32 %x to float
  %pow = tail call afn float @llvm.pow.f32(float 7.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_const_base_fast(i31 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = zext i31 [[X:%.*]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = tail call afn float @llvm.powi.f32.i32(float 7.000000e+00, i32 [[TMP1]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[TMP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i31 %x to float
  %pow = tail call afn float @llvm.pow.f32(float 7.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_sitofp_double_const_base_fast(i32 %x) {
; CHECK-LABEL: @pow_sitofp_double_const_base_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call afn double @llvm.powi.f64.i32(double 7.000000e+00, i32 [[X:%.*]])
; CHECK-NEXT:    ret double [[TMP1]]
;
  %subfp = sitofp i32 %x to double
  %pow = tail call afn double @llvm.pow.f64(double 7.000000e+00, double %subfp)
  ret double %pow
}

define double @pow_uitofp_double_const_base_fast(i31 %x) {
; CHECK-LABEL: @pow_uitofp_double_const_base_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = zext i31 [[X:%.*]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = tail call afn double @llvm.powi.f64.i32(double 7.000000e+00, i32 [[TMP1]])
; CHECK-NEXT:    ret double [[TMP2]]
;
  %subfp = uitofp i31 %x to double
  %pow = tail call afn double @llvm.pow.f64(double 7.000000e+00, double %subfp)
  ret double %pow
}

define double @pow_sitofp_double_const_base_2_fast(i32 %x) {
; CHECK-LABEL: @pow_sitofp_double_const_base_2_fast(
; CHECK-NEXT:    [[LDEXPF:%.*]] = tail call afn float @ldexpf(float 1.000000e+00, i32 [[X:%.*]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[LDEXPF]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = sitofp i32 %x to float
  %pow = tail call afn float @llvm.pow.f32(float 2.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_sitofp_double_const_base_power_of_2_fast(i32 %x) {
; CHECK-LABEL: @pow_sitofp_double_const_base_power_of_2_fast(
; CHECK-NEXT:    [[SUBFP:%.*]] = sitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[MUL:%.*]] = fmul afn float [[SUBFP]], 4.000000e+00
; CHECK-NEXT:    [[EXP2:%.*]] = tail call afn float @llvm.exp2.f32(float [[MUL]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[EXP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = sitofp i32 %x to float
  %pow = tail call afn float @llvm.pow.f32(float 16.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_const_base_2_fast(i31 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_2_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = zext i31 [[X:%.*]] to i32
; CHECK-NEXT:    [[LDEXPF:%.*]] = tail call afn float @ldexpf(float 1.000000e+00, i32 [[TMP1]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[LDEXPF]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i31 %x to float
  %pow = tail call afn float @llvm.pow.f32(float 2.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_const_base_power_of_2_fast(i31 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_power_of_2_fast(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i31 [[X:%.*]] to float
; CHECK-NEXT:    [[MUL:%.*]] = fmul afn float [[SUBFP]], 4.000000e+00
; CHECK-NEXT:    [[EXP2:%.*]] = tail call afn float @llvm.exp2.f32(float [[MUL]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[EXP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i31 %x to float
  %pow = tail call afn float @llvm.pow.f32(float 16.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_sitofp_float_base_fast(float %base, i32 %x) {
; CHECK-LABEL: @pow_sitofp_float_base_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call afn float @llvm.powi.f32.i32(float [[BASE:%.*]], i32 [[X:%.*]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[TMP1]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = sitofp i32 %x to float
  %pow = tail call afn float @llvm.pow.f32(float %base, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_float_base_fast(float %base, i31 %x) {
; CHECK-LABEL: @pow_uitofp_float_base_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = zext i31 [[X:%.*]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = tail call afn float @llvm.powi.f32.i32(float [[BASE:%.*]], i32 [[TMP1]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[TMP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i31 %x to float
  %pow = tail call afn float @llvm.pow.f32(float %base, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_sitofp_double_base_fast(double %base, i32 %x) {
; CHECK-LABEL: @pow_sitofp_double_base_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call afn double @llvm.powi.f64.i32(double [[BASE:%.*]], i32 [[X:%.*]])
; CHECK-NEXT:    ret double [[TMP1]]
;
  %subfp = sitofp i32 %x to double
  %res = tail call afn double @llvm.pow.f64(double %base, double %subfp)
  ret double %res
}

define double @pow_uitofp_double_base_fast(double %base, i31 %x) {
; CHECK-LABEL: @pow_uitofp_double_base_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = zext i31 [[X:%.*]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = tail call afn double @llvm.powi.f64.i32(double [[BASE:%.*]], i32 [[TMP1]])
; CHECK-NEXT:    ret double [[TMP2]]
;
  %subfp = uitofp i31 %x to double
  %res = tail call afn double @llvm.pow.f64(double %base, double %subfp)
  ret double %res
}

define double @pow_sitofp_const_base_fast_i8(i8 %x) {
; CHECK-LABEL: @pow_sitofp_const_base_fast_i8(
; CHECK-NEXT:    [[TMP1:%.*]] = sext i8 [[X:%.*]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = tail call afn float @llvm.powi.f32.i32(float 7.000000e+00, i32 [[TMP1]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[TMP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = sitofp i8 %x to float
  %pow = tail call afn float @llvm.pow.f32(float 7.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_sitofp_const_base_fast_i16(i16 %x) {
; CHECK-LABEL: @pow_sitofp_const_base_fast_i16(
; CHECK-NEXT:    [[TMP1:%.*]] = sext i16 [[X:%.*]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = tail call afn float @llvm.powi.f32.i32(float 7.000000e+00, i32 [[TMP1]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[TMP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = sitofp i16 %x to float
  %pow = tail call afn float @llvm.pow.f32(float 7.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}


define double @pow_uitofp_const_base_fast_i8(i8 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_fast_i8(
; CHECK-NEXT:    [[TMP1:%.*]] = zext i8 [[X:%.*]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = tail call afn float @llvm.powi.f32.i32(float 7.000000e+00, i32 [[TMP1]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[TMP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i8 %x to float
  %pow = tail call afn float @llvm.pow.f32(float 7.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_const_base_fast_i16(i16 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_fast_i16(
; CHECK-NEXT:    [[TMP1:%.*]] = zext i16 [[X:%.*]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = tail call afn float @llvm.powi.f32.i32(float 7.000000e+00, i32 [[TMP1]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[TMP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i16 %x to float
  %pow = tail call afn float @llvm.pow.f32(float 7.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @powf_exp_const_int_fast(double %base) {
; CHECK-LABEL: @powf_exp_const_int_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call fast double @llvm.powi.f64.i32(double [[BASE:%.*]], i32 40)
; CHECK-NEXT:    ret double [[TMP1]]
;
  %res = tail call fast double @llvm.pow.f64(double %base, double 4.000000e+01)
  ret double %res
}

define double @powf_exp_const2_int_fast(double %base) {
; CHECK-LABEL: @powf_exp_const2_int_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call fast double @llvm.powi.f64.i32(double [[BASE:%.*]], i32 -40)
; CHECK-NEXT:    ret double [[TMP1]]
;
  %res = tail call fast double @llvm.pow.f64(double %base, double -4.000000e+01)
  ret double %res
}

; Negative tests

define double @pow_uitofp_const_base_fast_i32(i32 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_fast_i32(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[MUL:%.*]] = fmul fast float [[SUBFP]], 0x4006757{{.*}}
; CHECK-NEXT:    [[EXP2:%.*]] = tail call fast float @llvm.exp2.f32(float [[MUL]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[EXP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i32 %x to float
  %pow = tail call fast float @llvm.pow.f32(float 7.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_const_base_2_fast_i32(i32 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_2_fast_i32(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[EXP2:%.*]] = tail call fast float @llvm.exp2.f32(float [[SUBFP]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[EXP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i32 %x to float
  %pow = tail call fast float @llvm.pow.f32(float 2.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_const_base_power_of_2_fast_i32(i32 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_power_of_2_fast_i32(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[MUL:%.*]] = fmul fast float [[SUBFP]], 4.000000e+00
; CHECK-NEXT:    [[EXP2:%.*]] = tail call fast float @llvm.exp2.f32(float [[MUL]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[EXP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i32 %x to float
  %pow = tail call fast float @llvm.pow.f32(float 16.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_float_base_fast_i32(float %base, i32 %x) {
; CHECK-LABEL: @pow_uitofp_float_base_fast_i32(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[POW:%.*]] = tail call fast float @llvm.pow.f32(float [[BASE:%.*]], float [[SUBFP]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[POW]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i32 %x to float
  %pow = tail call fast float @llvm.pow.f32(float %base, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_double_base_fast_i32(double %base, i32 %x) {
; CHECK-LABEL: @pow_uitofp_double_base_fast_i32(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i32 [[X:%.*]] to double
; CHECK-NEXT:    [[RES:%.*]] = tail call fast double @llvm.pow.f64(double [[BASE:%.*]], double [[SUBFP]])
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i32 %x to double
  %res = tail call fast double @llvm.pow.f64(double %base, double %subfp)
  ret double %res
}

define double @pow_sitofp_const_base_fast_i64(i64 %x) {
; CHECK-LABEL: @pow_sitofp_const_base_fast_i64(
; CHECK-NEXT:    [[SUBFP:%.*]] = sitofp i64 [[X:%.*]] to float
; Do not change 0x400675{{.*}} to the exact constant, see PR42740
; CHECK-NEXT:    [[MUL:%.*]] = fmul fast float [[SUBFP]], 0x400675{{.*}}
; CHECK-NEXT:    [[EXP2:%.*]] = tail call fast float @llvm.exp2.f32(float [[MUL]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[EXP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = sitofp i64 %x to float
  %pow = tail call fast float @llvm.pow.f32(float 7.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_const_base_fast_i64(i64 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_fast_i64(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i64 [[X:%.*]] to float
; CHECK-NEXT:    [[MUL:%.*]] = fmul fast float [[SUBFP]], 0x400675{{.*}}
; CHECK-NEXT:    [[EXP2:%.*]] = tail call fast float @llvm.exp2.f32(float [[MUL]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[EXP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i64 %x to float
  %pow = tail call fast float @llvm.pow.f32(float 7.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_sitofp_const_base_no_fast(i32 %x) {
; CHECK-LABEL: @pow_sitofp_const_base_no_fast(
; CHECK-NEXT:    [[SUBFP:%.*]] = sitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[POW:%.*]] = tail call float @llvm.pow.f32(float 7.000000e+00, float [[SUBFP]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[POW]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = sitofp i32 %x to float
  %pow = tail call float @llvm.pow.f32(float 7.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_const_base_no_fast(i32 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_no_fast(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[POW:%.*]] = tail call float @llvm.pow.f32(float 7.000000e+00, float [[SUBFP]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[POW]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i32 %x to float
  %pow = tail call float @llvm.pow.f32(float 7.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_sitofp_const_base_2_no_fast(i32 %x) {
; CHECK-LABEL: @pow_sitofp_const_base_2_no_fast(
; CHECK-NEXT:    [[LDEXPF:%.*]] = tail call float @ldexpf(float 1.000000e+00, i32 [[X:%.*]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[LDEXPF]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = sitofp i32 %x to float
  %pow = tail call float @llvm.pow.f32(float 2.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_sitofp_const_base_power_of_2_no_fast(i32 %x) {
; CHECK-LABEL: @pow_sitofp_const_base_power_of_2_no_fast(
; CHECK-NEXT:    [[SUBFP:%.*]] = sitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[SUBFP]], 4.000000e+00
; CHECK-NEXT:    [[EXP2:%.*]] = tail call float @llvm.exp2.f32(float [[MUL]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[EXP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = sitofp i32 %x to float
  %pow = tail call float @llvm.pow.f32(float 16.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_const_base_2_no_fast(i32 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_2_no_fast(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[EXP2:%.*]] = tail call float @llvm.exp2.f32(float [[SUBFP]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[EXP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i32 %x to float
  %pow = tail call float @llvm.pow.f32(float 2.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_const_base_power_of_2_no_fast(i32 %x) {
; CHECK-LABEL: @pow_uitofp_const_base_power_of_2_no_fast(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[SUBFP]], 4.000000e+00
; CHECK-NEXT:    [[EXP2:%.*]] = tail call float @llvm.exp2.f32(float [[MUL]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[EXP2]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i32 %x to float
  %pow = tail call float @llvm.pow.f32(float 16.000000e+00, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_sitofp_float_base_no_fast(float %base, i32 %x) {
; CHECK-LABEL: @pow_sitofp_float_base_no_fast(
; CHECK-NEXT:    [[SUBFP:%.*]] = sitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[POW:%.*]] = tail call float @llvm.pow.f32(float [[BASE:%.*]], float [[SUBFP]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[POW]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = sitofp i32 %x to float
  %pow = tail call float @llvm.pow.f32(float %base, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_uitofp_float_base_no_fast(float %base, i32 %x) {
; CHECK-LABEL: @pow_uitofp_float_base_no_fast(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i32 [[X:%.*]] to float
; CHECK-NEXT:    [[POW:%.*]] = tail call float @llvm.pow.f32(float [[BASE:%.*]], float [[SUBFP]])
; CHECK-NEXT:    [[RES:%.*]] = fpext float [[POW]] to double
; CHECK-NEXT:    ret double [[RES]]
;
  %subfp = uitofp i32 %x to float
  %pow = tail call float @llvm.pow.f32(float %base, float %subfp)
  %res = fpext float %pow to double
  ret double %res
}

define double @pow_sitofp_double_base_no_fast(double %base, i32 %x) {
; CHECK-LABEL: @pow_sitofp_double_base_no_fast(
; CHECK-NEXT:    [[SUBFP:%.*]] = sitofp i32 [[X:%.*]] to double
; CHECK-NEXT:    [[POW:%.*]] = tail call double @llvm.pow.f64(double [[BASE:%.*]], double [[SUBFP]])
; CHECK-NEXT:    ret double [[POW]]
;
  %subfp = sitofp i32 %x to double
  %pow = tail call double @llvm.pow.f64(double %base, double %subfp)
  ret double %pow
}

define double @pow_uitofp_double_base_no_fast(double %base, i32 %x) {
; CHECK-LABEL: @pow_uitofp_double_base_no_fast(
; CHECK-NEXT:    [[SUBFP:%.*]] = uitofp i32 [[X:%.*]] to double
; CHECK-NEXT:    [[POW:%.*]] = tail call double @llvm.pow.f64(double [[BASE:%.*]], double [[SUBFP]])
; CHECK-NEXT:    ret double [[POW]]
;
  %subfp = uitofp i32 %x to double
  %pow = tail call double @llvm.pow.f64(double %base, double %subfp)
  ret double %pow
}

; negative test - pow with no FMF is not the same as the loosely-specified powi

define double @powf_exp_const_int_no_fast(double %base) {
; CHECK-LABEL: @powf_exp_const_int_no_fast(
; CHECK-NEXT:    [[RES:%.*]] = tail call double @llvm.pow.f64(double [[BASE:%.*]], double 4.000000e+01)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = tail call double @llvm.pow.f64(double %base, double 4.000000e+01)
  ret double %res
}

define double @powf_exp_const_not_int_fast(double %base) {
; CHECK-LABEL: @powf_exp_const_not_int_fast(
; CHECK-NEXT:    [[SQRT:%.*]] = call fast double @llvm.sqrt.f64(double [[BASE:%.*]])
; CHECK-NEXT:    [[POWI:%.*]] = tail call fast double @llvm.powi.f64.i32(double [[BASE]], i32 37)
; CHECK-NEXT:    [[RES:%.*]] = fmul fast double [[POWI]], [[SQRT]]
; CHECK-NEXT:    ret double [[RES]]
;
  %res = tail call fast double @llvm.pow.f64(double %base, double 3.750000e+01)
  ret double %res
}

define double @powf_exp_const_not_int_no_fast(double %base) {
; CHECK-LABEL: @powf_exp_const_not_int_no_fast(
; CHECK-NEXT:    [[RES:%.*]] = tail call double @llvm.pow.f64(double [[BASE:%.*]], double 3.750000e+01)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = tail call double @llvm.pow.f64(double %base, double 3.750000e+01)
  ret double %res
}

; negative test - pow with no FMF is not the same as the loosely-specified powi

define double @powf_exp_const2_int_no_fast(double %base) {
; CHECK-LABEL: @powf_exp_const2_int_no_fast(
; CHECK-NEXT:    [[RES:%.*]] = tail call double @llvm.pow.f64(double [[BASE:%.*]], double -4.000000e+01)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = tail call double @llvm.pow.f64(double %base, double -4.000000e+01)
  ret double %res
}

; TODO: This could be transformed the same as scalar if there is an ldexp intrinsic.

define <2 x float> @pow_sitofp_const_base_2_no_fast_vector(<2 x i8> %x) {
; CHECK-LABEL: @pow_sitofp_const_base_2_no_fast_vector(
; CHECK-NEXT:    [[S:%.*]] = sitofp <2 x i8> [[X:%.*]] to <2 x float>
; CHECK-NEXT:    [[EXP2:%.*]] = call <2 x float> @llvm.exp2.v2f32(<2 x float> [[S]])
; CHECK-NEXT:    ret <2 x float> [[EXP2]]
;
  %s = sitofp <2 x i8> %x to <2 x float>
  %r = call <2 x float> @llvm.pow.v2f32(<2 x float><float 2.0, float 2.0>, <2 x float> %s)
  ret <2 x float> %r
}

declare float @llvm.pow.f32(float, float)
declare double @llvm.pow.f64(double, double)
declare <2 x float> @llvm.pow.v2f32(<2 x float>, <2 x float>)
