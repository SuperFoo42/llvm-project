//--------------------------------------------------------------------------------------------------
// WHEN CREATING A NEW TEST, PLEASE JUST COPY & PASTE WITHOUT EDITS.
//
// Set-up that's shared across all tests in this directory. In principle, this
// config could be moved to lit.local.cfg. However, there are downstream users that
//  do not use these LIT config files. Hence why this is kept inline.
//
// DEFINE: %{sparsifier_opts} = enable-runtime-library=true
// DEFINE: %{sparsifier_opts_sve} = enable-arm-sve=true %{sparsifier_opts}
// DEFINE: %{compile} = mlir-opt %s --sparsifier="%{sparsifier_opts}"
// DEFINE: %{compile_sve} = mlir-opt %s --sparsifier="%{sparsifier_opts_sve}"
// DEFINE: %{run_libs} = -shared-libs=%mlir_c_runner_utils,%mlir_runner_utils
// DEFINE: %{run_opts} = -e entry -entry-point-result=void
// DEFINE: %{run} = mlir-cpu-runner %{run_opts} %{run_libs}
// DEFINE: %{run_sve} = %mcr_aarch64_cmd --march=aarch64 --mattr="+sve" %{run_opts} %{run_libs}
//
// DEFINE: %{env} =
//--------------------------------------------------------------------------------------------------

// RUN: %{compile} | %{run} | FileCheck %s
//
// Do the same run, but now with direct IR generation.
// REDEFINE: %{sparsifier_opts} = enable-runtime-library=false
// RUN: %{compile} | %{run} | FileCheck %s
//
// Do the same run, but now with vectorization.
// REDEFINE: %{sparsifier_opts} = enable-runtime-library=false vl=2 reassociate-fp-reductions=true enable-index-optimizations=true
// RUN: %{compile} | %{run} | FileCheck %s
//
// Do the same run, but now with  VLA vectorization.
// RUN: %if mlir_arm_sve_tests %{ %{compile_sve} | %{run_sve} | FileCheck %s %}

#ST = #sparse_tensor.encoding<{lvlTypes = ["compressed", "compressed", "compressed"]}>

//
// Trait for 3-d tensor element wise multiplication.
//
#trait_mul = {
  indexing_maps = [
    affine_map<(i,j,k) -> (i,j,k)>,  // A (in)
    affine_map<(i,j,k) -> (i,j,k)>,  // B (in)
    affine_map<(i,j,k) -> (i,j,k)>   // X (out)
  ],
  iterator_types = ["parallel", "parallel", "parallel"],
  doc = "X(i,j,k) = A(i,j,k) * B(i,j,k)"
}

module {
  // Multiplies two 3-d sparse tensors element-wise into a new sparse tensor.
  func.func @tensor_mul(%arga: tensor<?x?x?xf64, #ST>,
                        %argb: tensor<?x?x?xf64, #ST>) -> tensor<?x?x?xf64, #ST> {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %d0 = tensor.dim %arga, %c0 : tensor<?x?x?xf64, #ST>
    %d1 = tensor.dim %arga, %c1 : tensor<?x?x?xf64, #ST>
    %d2 = tensor.dim %arga, %c2 : tensor<?x?x?xf64, #ST>
    %xt = bufferization.alloc_tensor(%d0, %d1, %d2) : tensor<?x?x?xf64, #ST>
    %0 = linalg.generic #trait_mul
       ins(%arga, %argb: tensor<?x?x?xf64, #ST>, tensor<?x?x?xf64, #ST>)
        outs(%xt: tensor<?x?x?xf64, #ST>) {
        ^bb(%a: f64, %b: f64, %x: f64):
          %1 = arith.mulf %a, %b : f64
          linalg.yield %1 : f64
    } -> tensor<?x?x?xf64, #ST>
    return %0 : tensor<?x?x?xf64, #ST>
  }

  // Driver method to call and verify tensor multiplication kernel.
  func.func @entry() {
    %c0 = arith.constant 0 : index
    %default_val = arith.constant -1.0 : f64

    // Setup sparse tensor A
    %ta = arith.constant dense<
      [ [ [1.0, 0.0, 0.0, 0.0, 0.0 ],
          [0.0, 0.0, 0.0, 0.0, 0.0 ],
          [1.2, 0.0, 3.5, 0.0, 0.0 ] ],
        [ [0.0, 0.0, 0.0, 0.0, 0.0 ],
          [0.0, 0.0, 0.0, 0.0, 0.0 ],
          [0.0, 0.0, 0.0, 0.0, 0.0 ] ],
        [ [2.0, 0.0, 0.0, 0.0, 0.0 ],
          [0.0, 0.0, 0.0, 0.0, 0.0 ],
          [0.0, 0.0, 4.0, 0.0, 0.0 ]] ]> : tensor<3x3x5xf64>

    // Setup sparse tensor B
    %tb = arith.constant dense<
      [ [ [0.0, 0.0, 0.0, 0.0, 4.0 ],
          [0.0, 0.0, 0.0, 0.0, 0.0 ],
          [2.0, 0.0, 1.0, 0.0, 0.0 ] ],
        [ [0.0, 0.0, 0.0, 0.0, 9.0 ],
          [0.0, 0.0, 0.0, 0.0, 0.0 ],
          [0.0, 7.0, 0.0, 0.0, 0.0 ] ],
        [ [1.0, 0.0, 0.0, 0.0, 0.0 ],
          [0.0, 0.0, 0.0, 0.0, 0.0 ],
          [0.0, 0.0, 2.0, 0.0, 0.0 ]] ]> : tensor<3x3x5xf64>

    %sta = sparse_tensor.convert %ta : tensor<3x3x5xf64> to tensor<?x?x?xf64, #ST>
    %stb = sparse_tensor.convert %tb : tensor<3x3x5xf64> to tensor<?x?x?xf64, #ST>


    // Call sparse tensor multiplication kernel.
    %0 = call @tensor_mul(%sta, %stb)
      : (tensor<?x?x?xf64, #ST>, tensor<?x?x?xf64, #ST>) -> tensor<?x?x?xf64, #ST>

    // Verify results
    //
    // CHECK:      4
    // CHECK-NEXT: ( 2.4, 3.5, 2, 8 )
    // CHECK-NEXT: ( ( ( 0, 0, 0, 0, 0 ), ( 0, 0, 0, 0, 0 ), ( 2.4, 0, 3.5, 0, 0 ) ),
    // CHECK-SAME: ( ( 0, 0, 0, 0, 0 ), ( 0, 0, 0, 0, 0 ), ( 0, 0, 0, 0, 0 ) ),
    // CHECK-SAME: ( ( 2, 0, 0, 0, 0 ), ( 0, 0, 0, 0, 0 ), ( 0, 0, 8, 0, 0 ) ) )
    //
    %n = sparse_tensor.number_of_entries %0 : tensor<?x?x?xf64, #ST>
    vector.print %n : index
    %m1 = sparse_tensor.values %0  : tensor<?x?x?xf64, #ST> to memref<?xf64>
    %v1 = vector.transfer_read %m1[%c0], %default_val: memref<?xf64>, vector<4xf64>
    vector.print %v1 : vector<4xf64>

    // Print %0 in dense form.
    %dt = sparse_tensor.convert %0 : tensor<?x?x?xf64, #ST> to tensor<?x?x?xf64>
    %v2 = vector.transfer_read %dt[%c0, %c0, %c0], %default_val: tensor<?x?x?xf64>, vector<3x3x5xf64>
    vector.print %v2 : vector<3x3x5xf64>

    // Release the resources.
    bufferization.dealloc_tensor %sta : tensor<?x?x?xf64, #ST>
    bufferization.dealloc_tensor %stb : tensor<?x?x?xf64, #ST>
    bufferization.dealloc_tensor %0  : tensor<?x?x?xf64, #ST>
    return
  }
}
