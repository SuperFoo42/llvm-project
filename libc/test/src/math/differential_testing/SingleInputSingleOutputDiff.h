//===-- Common utility class for differential analysis --------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/__support/FPUtil/FPBits.h"
#include "test/src/math/differential_testing/Timer.h"

#include <fstream>

namespace __llvm_libc {
namespace testing {

template <typename T> class SingleInputSingleOutputDiff {
  using FPBits = fputil::FPBits<T>;
  using StorageType = typename FPBits::StorageType;
  static constexpr StorageType UIntMax =
      cpp::numeric_limits<StorageType>::max();

public:
  typedef T Func(T);

  static void runDiff(Func myFunc, Func otherFunc, const char *logFile) {
    StorageType diffCount = 0;
    std::ofstream log(logFile);
    log << "Starting diff for values from 0 to " << UIntMax << '\n'
        << "Only differing results will be logged.\n\n";
    for (StorageType bits = 0;; ++bits) {
      T x = T(FPBits(bits));
      T myResult = myFunc(x);
      T otherResult = otherFunc(x);
      StorageType myBits = FPBits(myResult).uintval();
      StorageType otherBits = FPBits(otherResult).uintval();
      if (myBits != otherBits) {
        ++diffCount;
        log << "       Input: " << bits << " (" << x << ")\n"
            << "   My result: " << myBits << " (" << myResult << ")\n"
            << "Other result: " << otherBits << " (" << otherResult << ")\n"
            << '\n';
      }
      if (bits == UIntMax)
        break;
    }
    log << "Total number of differing results: " << diffCount << '\n';
  }

  static void runPerfInRange(Func myFunc, Func otherFunc,
                             StorageType startingBit, StorageType endingBit,
                             std::ofstream &log) {
    auto runner = [=](Func func) {
      volatile T result;
      for (StorageType bits = startingBit;; ++bits) {
        T x = T(FPBits(bits));
        result = func(x);
        if (bits == endingBit)
          break;
      }
    };

    Timer timer;
    timer.start();
    runner(myFunc);
    timer.stop();

    StorageType numberOfRuns = endingBit - startingBit + 1;
    double myAverage = static_cast<double>(timer.nanoseconds()) / numberOfRuns;
    log << "-- My function --\n";
    log << "     Total time      : " << timer.nanoseconds() << " ns \n";
    log << "     Average runtime : " << myAverage << " ns/op \n";
    log << "     Ops per second  : "
        << static_cast<uint64_t>(1'000'000'000.0 / myAverage) << " op/s \n";

    timer.start();
    runner(otherFunc);
    timer.stop();

    double otherAverage =
        static_cast<double>(timer.nanoseconds()) / numberOfRuns;
    log << "-- Other function --\n";
    log << "     Total time      : " << timer.nanoseconds() << " ns \n";
    log << "     Average runtime : " << otherAverage << " ns/op \n";
    log << "     Ops per second  : "
        << static_cast<uint64_t>(1'000'000'000.0 / otherAverage) << " op/s \n";

    log << "-- Average runtime ratio --\n";
    log << "     Mine / Other's  : " << myAverage / otherAverage << " \n";
  }

  static void runPerf(Func myFunc, Func otherFunc, const char *logFile) {
    std::ofstream log(logFile);
    log << " Performance tests with inputs in denormal range:\n";
    runPerfInRange(myFunc, otherFunc, /* startingBit= */ StorageType(0),
                   /* endingBit= */ FPBits::MAX_SUBNORMAL, log);
    log << "\n Performance tests with inputs in normal range:\n";
    runPerfInRange(myFunc, otherFunc, /* startingBit= */ FPBits::MIN_NORMAL,
                   /* endingBit= */ FPBits::MAX_NORMAL, log);
  }
};

} // namespace testing
} // namespace __llvm_libc

#define SINGLE_INPUT_SINGLE_OUTPUT_DIFF(T, myFunc, otherFunc, filename)        \
  int main() {                                                                 \
    __llvm_libc::testing::SingleInputSingleOutputDiff<T>::runDiff(             \
        &myFunc, &otherFunc, filename);                                        \
    return 0;                                                                  \
  }

#define SINGLE_INPUT_SINGLE_OUTPUT_PERF(T, myFunc, otherFunc, filename)        \
  int main() {                                                                 \
    __llvm_libc::testing::SingleInputSingleOutputDiff<T>::runPerf(             \
        &myFunc, &otherFunc, filename);                                        \
    return 0;                                                                  \
  }
