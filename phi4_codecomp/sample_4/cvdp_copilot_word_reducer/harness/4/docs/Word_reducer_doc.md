# Data Reduction Module Behavioral Specification

## Overview
The **Data Reduction** module processes multiple input data words and produces a single output data word by applying a bitwise reduction operation. For each bit position in the output word, the module combines the corresponding bits from all input data words using a specified reduction operation, such as AND, OR, XOR, NAND, NOR, or XNOR. Its parameterizable design supports a wide range of applications, including data compression and parallel data analysis.

---

## Module Descriptions

### 1. **Bitwise_Reduction**
The `Bitwise_Reduction` module performs a logical reduction operation on a group of input bits and outputs a single reduced bit. This operation is used within the `Data_Reduction` module to process bits at the same position across multiple data words.

**Parameters**:
- `REDUCTION_OP`: Defines the operation (AND, OR, XOR, etc.) to apply to the input bits. Default is AND (`3'b000`).
- `BIT_COUNT`: Specifies the number of input bits to process.

**Inputs**:
- A group of input bits to reduce.

**Outputs**:
- The single-bit result of the reduction operation.

---

### 2. **Data_Reduction**
The `Data_Reduction` module combines multiple input data words into a single output word by performing a reduction operation for each bit position. The reduction is handled by instances of the `Bitwise_Reduction` module for modularity and scalability.

**Parameters**:
- `REDUCTION_OP`: Specifies the bitwise operation to apply. Default is AND (`3'b000`).
- `DATA_WIDTH`: Defines the number of bits per data word.
- `DATA_COUNT`: Defines the number of input data words.
- `TOTAL_INPUT_WIDTH`: Represents the width of the concatenated input (`DATA_WIDTH * DATA_COUNT`).

**Inputs**:
- Concatenated input data words, arranged sequentially.

**Outputs**:
- A single data word formed by applying the reduction operation across corresponding bits of the input data words.

---

## Functional Description

### **Bit Extraction**
1. For each bit position from `0` to `DATA_WIDTH-1`, the module identifies the bits at that position across all input data words.
2. These bits are grouped together into a set, containing all the bits from the same position across the input data words.

### **Bitwise Reduction Process**
1. For each bit position, the set of bits extracted for that position is processed using the specified reduction operation, producing a single reduced bit.
2. This process is repeated independently for all bit positions.

### **Output Assembly**
1. The reduced bits from all bit positions are combined sequentially to form the output word.
2. The result is a data word of width `DATA_WIDTH`, where each bit represents the reduced value of corresponding bits from the input words.

---

## Supported Reduction Operations
- **AND (`3'b000`)**: Produces a `1` if all bits are `1`, otherwise `0`.
- **OR (`3'b001`)**: Produces a `1` if at least one bit is `1`, otherwise `0`.
- **XOR (`3'b010`)**: Produces a `1` if an odd number of bits are `1`, otherwise `0`.
- **NAND (`3'b011`)**: Inverted AND.
- **NOR (`3'b100`)**: Inverted OR.
- **XNOR (`3'b101`)**: Inverted XOR.  
The default operation is AND, which ensures basic functionality if no operation is explicitly specified.

---

## Example Operation

### Configuration:
- `REDUCTION_OP`: OR (`3'b001`)
- `DATA_WIDTH`: 4
- `DATA_COUNT`: 4
- `data_in`: `{4'b1100, 4'b1010, 4'b1001, 4'b0110}`

### Process:
1. **For Bit Position 0**:
   - Extracted Bits: `0, 0, 1, 0`
   - Apply OR: `0 | 0 | 1 | 0 = 1`
   - Output: `reduced_data_out[0] = 1`

2. **For Bit Position 1**:
   - Extracted Bits: `0, 1, 0, 1`
   - Apply OR: `0 | 1 | 0 | 1 = 1`
   - Output: `reduced_data_out[1] = 1`

3. **For Bit Position 2**:
   - Extracted Bits: `1, 0, 0, 1`
   - Apply OR: `1 | 0 | 0 | 1 = 1`
   - Output: `reduced_data_out[2] = 1`

4. **For Bit Position 3**:
   - Extracted Bits: `1, 1, 1, 0`
   - Apply OR: `1 | 1 | 1 | 0 = 1`
   - Output: `reduced_data_out[3] = 1`

### Final Output:
- `reduced_data_out = 4'b1111`
