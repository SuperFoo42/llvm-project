//=- AArch64MachineFunctionInfo.cpp - AArch64 Machine Function Info ---------=//

//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file implements AArch64-specific per-machine-function
/// information.
///
//===----------------------------------------------------------------------===//

#include "AArch64MachineFunctionInfo.h"
#include "AArch64InstrInfo.h"
#include "AArch64Subtarget.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Module.h"
#include "llvm/MC/MCAsmInfo.h"

using namespace llvm;

yaml::AArch64FunctionInfo::AArch64FunctionInfo(
    const llvm::AArch64FunctionInfo &MFI)
    : HasRedZone(MFI.hasRedZone()) {}

void yaml::AArch64FunctionInfo::mappingImpl(yaml::IO &YamlIO) {
  MappingTraits<AArch64FunctionInfo>::mapping(YamlIO, *this);
}

void AArch64FunctionInfo::initializeBaseYamlFields(
    const yaml::AArch64FunctionInfo &YamlMFI) {
  if (YamlMFI.HasRedZone)
    HasRedZone = YamlMFI.HasRedZone;
}

static std::pair<bool, bool> GetSignReturnAddress(const Function &F) {
  // The function should be signed in the following situations:
  // - sign-return-address=all
  // - sign-return-address=non-leaf and the functions spills the LR
  if (!F.hasFnAttribute("sign-return-address")) {
    const Module &M = *F.getParent();
    if (const auto *Sign = mdconst::extract_or_null<ConstantInt>(
            M.getModuleFlag("sign-return-address"))) {
      if (Sign->getZExtValue()) {
        if (const auto *All = mdconst::extract_or_null<ConstantInt>(
                M.getModuleFlag("sign-return-address-all")))
          return {true, All->getZExtValue()};
        return {true, false};
      }
    }
    return {false, false};
  }

  StringRef Scope = F.getFnAttribute("sign-return-address").getValueAsString();
  if (Scope.equals("none"))
    return {false, false};

  if (Scope.equals("all"))
    return {true, true};

  assert(Scope.equals("non-leaf"));
  return {true, false};
}

static bool ShouldSignWithBKey(const Function &F, const AArch64Subtarget &STI) {
  if (!F.hasFnAttribute("sign-return-address-key")) {
    if (const auto *BKey = mdconst::extract_or_null<ConstantInt>(
            F.getParent()->getModuleFlag("sign-return-address-with-bkey")))
      return BKey->getZExtValue();
    if (STI.getTargetTriple().isOSWindows())
      return true;
    return false;
  }

  const StringRef Key =
      F.getFnAttribute("sign-return-address-key").getValueAsString();
  assert(Key == "a_key" || Key == "b_key");
  return Key == "b_key";
}

AArch64FunctionInfo::AArch64FunctionInfo(const Function &F,
                                         const AArch64Subtarget *STI) {
  // If we already know that the function doesn't have a redzone, set
  // HasRedZone here.
  if (F.hasFnAttribute(Attribute::NoRedZone))
    HasRedZone = false;
  std::tie(SignReturnAddress, SignReturnAddressAll) = GetSignReturnAddress(F);
  SignWithBKey = ShouldSignWithBKey(F, *STI);
  // TODO: skip functions that have no instrumented allocas for optimization
  IsMTETagged = F.hasFnAttribute(Attribute::SanitizeMemTag);

  // BTI/PAuthLR may be set either on the function or the module. Set Bool from
  // either the function attribute or module attribute, depending on what is
  // set.
  // Note: the module attributed is numeric (0 or 1) but the function attribute
  // is stringy ("true" or "false").
  auto TryFnThenModule = [&](StringRef AttrName, bool &Bool) {
    if (F.hasFnAttribute(AttrName)) {
      const StringRef V = F.getFnAttribute(AttrName).getValueAsString();
      assert(V.equals_insensitive("true") || V.equals_insensitive("false"));
      Bool = V.equals_insensitive("true");
    } else if (const auto *ModVal = mdconst::extract_or_null<ConstantInt>(
                   F.getParent()->getModuleFlag(AttrName))) {
      Bool = ModVal->getZExtValue();
    }
  };

  TryFnThenModule("branch-target-enforcement", BranchTargetEnforcement);
  TryFnThenModule("branch-protection-pauth-lr", BranchProtectionPAuthLR);

  // The default stack probe size is 4096 if the function has no
  // stack-probe-size attribute. This is a safe default because it is the
  // smallest possible guard page size.
  uint64_t ProbeSize = 4096;
  if (F.hasFnAttribute("stack-probe-size"))
    ProbeSize = F.getFnAttributeAsParsedInteger("stack-probe-size");
  else if (const auto *PS = mdconst::extract_or_null<ConstantInt>(
               F.getParent()->getModuleFlag("stack-probe-size")))
    ProbeSize = PS->getZExtValue();
  assert(int64_t(ProbeSize) > 0 && "Invalid stack probe size");

  if (STI->isTargetWindows()) {
    if (!F.hasFnAttribute("no-stack-arg-probe"))
      StackProbeSize = ProbeSize;
  } else {
    // Round down to the stack alignment.
    uint64_t StackAlign =
        STI->getFrameLowering()->getTransientStackAlign().value();
    ProbeSize = std::max(StackAlign, ProbeSize & ~(StackAlign - 1U));
    StringRef ProbeKind;
    if (F.hasFnAttribute("probe-stack"))
      ProbeKind = F.getFnAttribute("probe-stack").getValueAsString();
    else if (const auto *PS = dyn_cast_or_null<MDString>(
                 F.getParent()->getModuleFlag("probe-stack")))
      ProbeKind = PS->getString();
    if (ProbeKind.size()) {
      if (ProbeKind != "inline-asm")
        report_fatal_error("Unsupported stack probing method");
      StackProbeSize = ProbeSize;
    }
  }
}

MachineFunctionInfo *AArch64FunctionInfo::clone(
    BumpPtrAllocator &Allocator, MachineFunction &DestMF,
    const DenseMap<MachineBasicBlock *, MachineBasicBlock *> &Src2DstMBB)
    const {
  return DestMF.cloneInfo<AArch64FunctionInfo>(*this);
}

bool AArch64FunctionInfo::shouldSignReturnAddress(bool SpillsLR) const {
  if (!SignReturnAddress)
    return false;
  if (SignReturnAddressAll)
    return true;
  return SpillsLR;
}

bool AArch64FunctionInfo::shouldSignReturnAddress(
    const MachineFunction &MF) const {
  return shouldSignReturnAddress(llvm::any_of(
      MF.getFrameInfo().getCalleeSavedInfo(),
      [](const auto &Info) { return Info.getReg() == AArch64::LR; }));
}

bool AArch64FunctionInfo::needsDwarfUnwindInfo(
    const MachineFunction &MF) const {
  if (!NeedsDwarfUnwindInfo)
    NeedsDwarfUnwindInfo = MF.needsFrameMoves() &&
                           !MF.getTarget().getMCAsmInfo()->usesWindowsCFI();

  return *NeedsDwarfUnwindInfo;
}

bool AArch64FunctionInfo::needsAsyncDwarfUnwindInfo(
    const MachineFunction &MF) const {
  if (!NeedsAsyncDwarfUnwindInfo) {
    const Function &F = MF.getFunction();
    //  The check got "minsize" is because epilogue unwind info is not emitted
    //  (yet) for homogeneous epilogues, outlined functions, and functions
    //  outlined from.
    NeedsAsyncDwarfUnwindInfo = needsDwarfUnwindInfo(MF) &&
                                F.getUWTableKind() == UWTableKind::Async &&
                                !F.hasMinSize();
  }
  return *NeedsAsyncDwarfUnwindInfo;
}
