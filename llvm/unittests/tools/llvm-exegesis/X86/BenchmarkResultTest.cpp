//===-- BenchmarkResultTest.cpp ---------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "BenchmarkResult.h"
#include "X86InstrInfo.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Error.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/YAMLTraits.h"
#include "llvm/Support/raw_ostream.h"
#include "gmock/gmock.h"
#include "gtest/gtest.h"

using ::testing::AllOf;
using ::testing::ElementsAre;
using ::testing::Eq;
using ::testing::Field;
using ::testing::get;
using ::testing::Pointwise;
using ::testing::Property;

namespace llvm {
namespace exegesis {

void InitializeX86ExegesisTarget();

static std::string Dump(const MCInst &McInst) {
  std::string Buffer;
  raw_string_ostream OS(Buffer);
  McInst.print(OS);
  return Buffer;
}

MATCHER(EqMCInst, "") {
  const std::string Lhs = Dump(get<0>(arg));
  const std::string Rhs = Dump(get<1>(arg));
  if (Lhs != Rhs) {
    *result_listener << Lhs << " <=> " << Rhs;
    return false;
  }
  return true;
}

MATCHER(EqRegValue, "") {
  const RegisterValue Lhs = get<0>(arg);
  const RegisterValue Rhs = get<1>(arg);
  if (Lhs.Register != Rhs.Register || Lhs.Value != Rhs.Value)
    return false;

  return true;
}

namespace {

TEST(BenchmarkResultTest, WriteToAndReadFromDisk) {
  LLVMInitializeX86TargetInfo();
  LLVMInitializeX86Target();
  LLVMInitializeX86TargetMC();
  InitializeX86ExegesisTarget();

  // Read benchmarks.
  const LLVMState State =
      cantFail(LLVMState::Create("x86_64-unknown-linux", "haswell"));

  ExitOnError ExitOnErr;

  Benchmark ToDisk;

  ToDisk.Key.Instructions.push_back(MCInstBuilder(X86::XOR32rr)
                                        .addReg(X86::AL)
                                        .addReg(X86::AH)
                                        .addImm(123)
                                        .addDFPImm(bit_cast<uint64_t>(0.5)));
  ToDisk.Key.Config = "config";
  ToDisk.Key.RegisterInitialValues = {
      RegisterValue{X86::AL, APInt(8, "-1", 10)},
      RegisterValue{X86::AH, APInt(8, "123", 10)}};
  ToDisk.Mode = Benchmark::Latency;
  ToDisk.CpuName = "cpu_name";
  ToDisk.LLVMTriple = "llvm_triple";
  ToDisk.NumRepetitions = 1;
  ToDisk.Measurements.push_back(BenchmarkMeasure{"a", 1, 1});
  ToDisk.Measurements.push_back(BenchmarkMeasure{"b", 2, 2});
  ToDisk.Error = "error";
  ToDisk.Info = "info";

  SmallString<64> Filename;
  std::error_code EC;
  EC = sys::fs::createUniqueDirectory("BenchmarkResultTestDir", Filename);
  ASSERT_FALSE(EC);
  sys::path::append(Filename, "data.yaml");
  errs() << Filename << "-------\n";
  {
    int ResultFD = 0;
    // Create output file or open existing file and truncate it, once.
    ExitOnErr(errorCodeToError(openFileForWrite(Filename, ResultFD,
                                                sys::fs::CD_CreateAlways,
                                                sys::fs::OF_TextWithCRLF)));
    raw_fd_ostream FileOstr(ResultFD, true /*shouldClose*/);

    ExitOnErr(ToDisk.writeYamlTo(State, FileOstr));
  }

  const std::unique_ptr<MemoryBuffer> Buffer =
      std::move(*MemoryBuffer::getFile(Filename));

  {
    // Read Triples/Cpu only.
    const auto TriplesAndCpus =
        ExitOnErr(Benchmark::readTriplesAndCpusFromYamls(*Buffer));

    ASSERT_THAT(TriplesAndCpus,
                testing::ElementsAre(
                    AllOf(Field(&Benchmark::TripleAndCpu::LLVMTriple,
                                Eq("llvm_triple")),
                          Field(&Benchmark::TripleAndCpu::CpuName,
                                Eq("cpu_name")))));
  }
  {
    // One-element version.
    const auto FromDisk =
        ExitOnErr(Benchmark::readYaml(State, *Buffer));

    EXPECT_THAT(FromDisk.Key.Instructions,
                Pointwise(EqMCInst(), ToDisk.Key.Instructions));
    EXPECT_EQ(FromDisk.Key.Config, ToDisk.Key.Config);
    EXPECT_THAT(FromDisk.Key.RegisterInitialValues,
                Pointwise(EqRegValue(), ToDisk.Key.RegisterInitialValues));
    EXPECT_EQ(FromDisk.Mode, ToDisk.Mode);
    EXPECT_EQ(FromDisk.CpuName, ToDisk.CpuName);
    EXPECT_EQ(FromDisk.LLVMTriple, ToDisk.LLVMTriple);
    EXPECT_EQ(FromDisk.NumRepetitions, ToDisk.NumRepetitions);
    EXPECT_THAT(FromDisk.Measurements, ToDisk.Measurements);
    EXPECT_THAT(FromDisk.Error, ToDisk.Error);
    EXPECT_EQ(FromDisk.Info, ToDisk.Info);
  }
  {
    // Vector version.
    const auto FromDiskVector =
        ExitOnErr(Benchmark::readYamls(State, *Buffer));
    ASSERT_EQ(FromDiskVector.size(), size_t{1});
    const auto &FromDisk = FromDiskVector[0];
    EXPECT_THAT(FromDisk.Key.Instructions,
                Pointwise(EqMCInst(), ToDisk.Key.Instructions));
    EXPECT_EQ(FromDisk.Key.Config, ToDisk.Key.Config);
    EXPECT_THAT(FromDisk.Key.RegisterInitialValues,
                Pointwise(EqRegValue(), ToDisk.Key.RegisterInitialValues));
    EXPECT_EQ(FromDisk.Mode, ToDisk.Mode);
    EXPECT_EQ(FromDisk.CpuName, ToDisk.CpuName);
    EXPECT_EQ(FromDisk.LLVMTriple, ToDisk.LLVMTriple);
    EXPECT_EQ(FromDisk.NumRepetitions, ToDisk.NumRepetitions);
    EXPECT_THAT(FromDisk.Measurements, ToDisk.Measurements);
    EXPECT_THAT(FromDisk.Error, ToDisk.Error);
    EXPECT_EQ(FromDisk.Info, ToDisk.Info);
  }
}

TEST(BenchmarkResultTest, PerInstructionStats) {
  PerInstructionStats Stats;
  Stats.push(BenchmarkMeasure{"a", 0.5, 0.0});
  Stats.push(BenchmarkMeasure{"a", 1.5, 0.0});
  Stats.push(BenchmarkMeasure{"a", -1.0, 0.0});
  Stats.push(BenchmarkMeasure{"a", 0.0, 0.0});
  EXPECT_EQ(Stats.min(), -1.0);
  EXPECT_EQ(Stats.max(), 1.5);
  EXPECT_EQ(Stats.avg(), 0.25); // (0.5+1.5-1.0+0.0) / 4
}
} // namespace
} // namespace exegesis
} // namespace llvm
