//===- DirectXTargetMachine.cpp - DirectX Target Implementation -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file contains DirectX target initializer.
///
//===----------------------------------------------------------------------===//

#include "DirectXTargetMachine.h"
#include "DXILResourceAnalysis.h"
#include "DXILShaderFlags.h"
#include "DXILWriter/DXILWriterPass.h"
#include "DirectX.h"
#include "DirectXSubtarget.h"
#include "DirectXTargetTransformInfo.h"
#include "TargetInfo/DirectXTargetInfo.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/MC/MCSectionDXContainer.h"
#include "llvm/MC/SectionKind.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Target/TargetLoweringObjectFile.h"
#include <optional>

using namespace llvm;

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeDirectXTarget() {
  RegisterTargetMachine<DirectXTargetMachine> X(getTheDirectXTarget());
  auto *PR = PassRegistry::getPassRegistry();
  initializeDXILPrepareModulePass(*PR);
  initializeEmbedDXILPassPass(*PR);
  initializeWriteDXILPassPass(*PR);
  initializeDXContainerGlobalsPass(*PR);
  initializeDXILOpLoweringLegacyPass(*PR);
  initializeDXILTranslateMetadataPass(*PR);
  initializeDXILResourceWrapperPass(*PR);
  initializeShaderFlagsAnalysisWrapperPass(*PR);
}

class DXILTargetObjectFile : public TargetLoweringObjectFile {
public:
  DXILTargetObjectFile() = default;

  MCSection *getExplicitSectionGlobal(const GlobalObject *GO, SectionKind Kind,
                                      const TargetMachine &TM) const override {
    return getContext().getDXContainerSection(GO->getSection(), Kind);
  }

protected:
  MCSection *SelectSectionForGlobal(const GlobalObject *GO, SectionKind Kind,
                                    const TargetMachine &TM) const override {
    llvm_unreachable("Not supported!");
  }
};

class DirectXPassConfig : public TargetPassConfig {
public:
  DirectXPassConfig(DirectXTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  DirectXTargetMachine &getDirectXTargetMachine() const {
    return getTM<DirectXTargetMachine>();
  }

  FunctionPass *createTargetRegisterAllocator(bool) override { return nullptr; }
  void addCodeGenPrepare() override {
    addPass(createDXILOpLoweringLegacyPass());
    addPass(createDXILPrepareModulePass());
    addPass(createDXILTranslateMetadataPass());
  }
};

DirectXTargetMachine::DirectXTargetMachine(const Target &T, const Triple &TT,
                                           StringRef CPU, StringRef FS,
                                           const TargetOptions &Options,
                                           std::optional<Reloc::Model> RM,
                                           std::optional<CodeModel::Model> CM,
                                           CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T,
                        "e-m:e-p:32:32-i1:32-i8:8-i16:16-i32:32-i64:64-f16:16-"
                        "f32:32-f64:64-n8:16:32:64",
                        TT, CPU, FS, Options, Reloc::Static, CodeModel::Small,
                        OL),
      TLOF(std::make_unique<DXILTargetObjectFile>()),
      Subtarget(std::make_unique<DirectXSubtarget>(TT, CPU, FS, *this)) {
  initAsmInfo();
}

DirectXTargetMachine::~DirectXTargetMachine() {}

void DirectXTargetMachine::registerPassBuilderCallbacks(
    PassBuilder &PB, bool PopulateClassToPassNames) {
  PB.registerPipelineParsingCallback(
      [](StringRef PassName, ModulePassManager &PM,
         ArrayRef<PassBuilder::PipelineElement>) {
        if (PassName == "print-dxil-resource") {
          PM.addPass(DXILResourcePrinterPass(dbgs()));
          return true;
        }
        if (PassName == "print-dx-shader-flags") {
          PM.addPass(dxil::ShaderFlagsAnalysisPrinter(dbgs()));
          return true;
        }
        return false;
      });

  PB.registerAnalysisRegistrationCallback([](ModuleAnalysisManager &MAM) {
    MAM.registerPass([&] { return DXILResourceAnalysis(); });
    MAM.registerPass([&] { return dxil::ShaderFlagsAnalysis(); });
  });
}

bool DirectXTargetMachine::addPassesToEmitFile(
    PassManagerBase &PM, raw_pwrite_stream &Out, raw_pwrite_stream *DwoOut,
    CodeGenFileType FileType, bool DisableVerify,
    MachineModuleInfoWrapperPass *MMIWP) {
  TargetPassConfig *PassConfig = createPassConfig(PM);
  PassConfig->addCodeGenPrepare();

  switch (FileType) {
  case CGFT_AssemblyFile:
    PM.add(createDXILPrettyPrinterPass(Out));
    PM.add(createPrintModulePass(Out, "", true));
    break;
  case CGFT_ObjectFile:
    if (TargetPassConfig::willCompleteCodeGenPipeline()) {
      PM.add(createDXILEmbedderPass());
      // We embed the other DXContainer globals after embedding DXIL so that the
      // globals don't pollute the DXIL.
      PM.add(createDXContainerGlobalsPass());

      if (!MMIWP)
        MMIWP = new MachineModuleInfoWrapperPass(this);
      PM.add(MMIWP);
      if (addAsmPrinter(PM, Out, DwoOut, FileType,
                        MMIWP->getMMI().getContext()))
        return true;
    } else
      PM.add(createDXILWriterPass(Out));
    break;
  case CGFT_Null:
    break;
  }
  return false;
}

bool DirectXTargetMachine::addPassesToEmitMC(PassManagerBase &PM,
                                             MCContext *&Ctx,
                                             raw_pwrite_stream &Out,
                                             bool DisableVerify) {
  return true;
}

TargetPassConfig *DirectXTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new DirectXPassConfig(*this, PM);
}

const DirectXSubtarget *
DirectXTargetMachine::getSubtargetImpl(const Function &) const {
  return Subtarget.get();
}

TargetTransformInfo
DirectXTargetMachine::getTargetTransformInfo(const Function &F) const {
  return TargetTransformInfo(DirectXTTIImpl(this, F));
}

DirectXTargetLowering::DirectXTargetLowering(const DirectXTargetMachine &TM,
                                             const DirectXSubtarget &STI)
    : TargetLowering(TM) {}
