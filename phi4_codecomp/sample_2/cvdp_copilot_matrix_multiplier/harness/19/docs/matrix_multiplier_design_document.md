# Matrix Multiplier Design Document

## Introduction

The `matrix_multiplier` module is a parameterized SystemVerilog design that performs matrix multiplication over multiple clock cycles with optimized latency. The design leverages a binary reduction tree in the accumulation stage, reducing the latency to `$clog2(COL_A) + 2` cycles. It supports matrices with configurable dimensions, unsigned inputs, and a fixed multi-cycle latency. The design structure consists of three main computational stages: multiplication, binary reduction tree accumulation, and output. This approach improves timing performance, making the design scalable for larger matrices, with the total latency of each multiplication operation being **`$clog2(COL_A) + 2` clock cycles**.

---

## Specifications for `matrix_multiplier` Module

### Inputs

- **clk**: Clock signal used to synchronize the computational stages.
- **srst**: Active-high synchronous reset. When high, it clears internal registers and outputs.
- **valid_in**: An active-high signal indicating that the input matrices are valid and ready to be processed.
- **matrix_a[(ROW_A x COL_A x INPUT_DATA_WIDTH) -1 : 0]**: Flattened input matrix A, containing unsigned elements.
- **matrix_b[(ROW_B x COL_B x INPUT_DATA_WIDTH) -1 : 0]**: Flattened input matrix B, containing unsigned elements.

### Outputs

- **valid_out**: An active-high signal indicating that the output matrix `matrix_c` is valid and ready.
- **matrix_c[(ROW_A x COL_B x OUTPUT_DATA_WIDTH) -1 : 0]**: Flattened output matrix C, containing unsigned elements with the final results of the matrix multiplication. The output updates along with `valid_out` assertion.

### Parameters

- **ROW_A**: Number of rows in `matrix_a`. Default value: 4.
- **COL_A**: Number of columns in `matrix_a`. Default value: 4.
- **ROW_B**: Number of rows in `matrix_b`, which must be equal to `COL_A`. Default value: 4.
- **COL_B**: Number of columns in `matrix_b`. Default value: 4.
- **INPUT_DATA_WIDTH**: Bit-width of each unsigned input element in the matrices. Default value: 8.
- **OUTPUT_DATA_WIDTH**: Bit-width of each element in `matrix_c`, calculated as `(INPUT_DATA_WIDTH * 2) + $clog2(COL_A)` to handle potential overflow during accumulation.

### Design Details

The design operates across three main computational stages: **Multiplication**, **Binary Reduction Tree Accumulation**, and **Output**. Each stage processes data over a series of clock cycles to complete the matrix multiplication operation.

### Computational Stages

1. **Multiplication Stage**: 
   - In the **multiplication stage**, the module computes the unsigned products of all corresponding elements from `matrix_a` and `matrix_b` in 1 clock cycle. These results are stored in intermediate registers. 

2. **Binary Reduction Tree Accumulation Stage**: 
   - In the **accumulation stage**, the module uses a binary reduction tree to accumulate the unsigned products across multiple cycles (over `$clog2(COL_A)` clock cycles) to obtain the final values for each element in `matrix_c`. This method adds pairs of partial sums in parallel, reducing the number of sums required by half in each cycle until only one sum remains per output element.

   - **Binary Reduction Tree Explanation**:
     - In a binary reduction tree, pairs of partial sums are added together in parallel, reducing the total number of sums by half in each clock cycle. This process repeats until only a single sum remains for each output matrix element.
     - For example, if there are 8 partial sums, they would be reduced as follows:
       - In the first cycle, add pairs (4 additions in parallel).
       - In the next cycle, add the results of the previous additions (2 additions in parallel).
       - In the final cycle, add the last two results to get a single accumulated sum.

3. **Output Stage**: 
   - In the output stage, the accumulated results in `add_stage` are transferred to `matrix_c`. The module asserts `valid_out`, signaling that the output matrix is ready. The `valid_out` signal aligns with `matrix_c` after the fixed latency of **`$clog2(COL_A) + 2` clock cycles**.

### Valid Signal Propagation

The `valid_in` signal initiates the computation process and propagates through a shift register (`valid_out_reg`) to synchronize with the computation stages. This shift register delays `valid_out` by **`$clog2(COL_A) + 2` clock cycles**, aligning it with the availability of the final output matrix `matrix_c`. This delay mechanism ensures that `valid_out` asserts only when `matrix_c` is ready.

### Handling of Zero-Width Vectors

To ensure robust synthesis, the design includes a special case for scenarios where `COL_A = 1`, where the binary reduction tree could otherwise generate zero-width vectors, leading to synthesis errors. In this situation, the design bypasses the reduction tree and directly assigns values from `mult_stage` to `matrix_c`.

### Reset Behavior

When the synchronous reset (`srst`) is asserted, all registers (including intermediate multiplication and accumulation registers) and the outputs are reset to their initial state of 0 on the next rising clock edge.

---

### Example of Matrix Flattening:

Suppose you have two input matrices A and B to multiply:

- **Matrix A (2x3)**:

```text
| a11  a12  a13 |
| a21  a22  a23 |
```

- **Matrix B (3x2)**:

```text
| b11  b12 |
| b21  b22 |
| b31  b32 |
```

The resulting output matrix from the multiplication of the above matrices would be:

- **Matrix C (2x2)**:

```text
| c11  c12 |
| c21  c22 |
```

The flattened representation of these matrices will be as follows:

- **Flattened Matrix A (2x3)**:

```text
matrix_a = {a23, a22, a21, a13, a12, a11}
```

- **Flattened Matrix B (3x2)**:

```text
matrix_b = {b32, b31, b22, b21, b12, b11}
```

- **Flattened Matrix C (2x2)**:

```text
matrix_c = {c22, c21, c12, c11}
```

### Timing and Synchronization:
- **Clock Signal:** All stages (multiplication, binary reduction tree accumulation, and output) should be synchronized to the rising edge of the clock (`clk`).
- **Latency:** The total latency from `valid_in` to `valid_out` should be **`$clog2(COL_A) + 2` cycles** .

### Constraints:
- **Input Control:** New inputs will only be applied from the next cycle following the assertion of `valid_out`, signaling that the module is ready for a new calculation.