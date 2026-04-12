# Functional Specification for `hamming_rx` Module

## Overview

The `hamming_rx` module is a parameterized SystemVerilog design that implements the decoding functionality for Hamming-coded data. It detects and corrects single-bit errors in the received encoded data and extracts the original data bits.

---

## Parameters

1. **`DATA_WIDTH`**: Width of the original data bits. Default value: 4.
2. **`PARITY_BIT`**: Number of parity bits in the Hamming code. Default value: 3.
   - The number of parity bits should be the minimum integer value that satisfies the Hamming code formula:  
     [ 2^p >= (p + m + 1) ],  where `p` is the number of parity bits and `m` is the width of the data 
3. **`ENCODED_DATA`**: Total width of the encoded data, including data bits, parity bits, and a redundant bit. Defined as `DATA_WIDTH + PARITY_BIT + 1`.
4. **`ENCODED_DATA_BIT`**: Number of bits required to address positions in the `ENCODED_DATA` vector, calculated as `$clog2(ENCODED_DATA)`.

---

## Inputs

- **`data_in[ENCODED_DATA-1:0]`**: Encoded data input containing the original data bits, parity bits, and a redundant bit.

---

## Outputs

- **`data_out[DATA_WIDTH-1:0]`**: Decoded output containing the corrected original data bits.

---

## Functional Description

### Parity Check Computation

Each parity bit is computed by performing an XOR operation over specific bits of the `data_in`. The specific bits included in each parity calculation are determined by the bit positions in `data_in` whose binary indices have the nth bit (counting from the least significant bit) set to 1. For example:
- The first parity bit (parity bit 0) checks all bit positions in `data_in` where the least significant bit of the binary index is 1 (e.g., positions 1, 3, 5, 7, etc.).
- The second parity bit (parity bit 1) checks all bit positions in `data_in` where the second least significant bit of the binary index is 1 (e.g., positions 2, 3, 6, 7, etc.).
- This pattern continues for all parity bits.

---

### Error Detection and Correction

The combined parity check results form a multi-bit value, which identifies the position of a single-bit error in `data_in` if any exists. 
If the parity check result identifies an error, the module corrects it by flipping the bit at the indicated position.  
**Note**: The redundant bit at position 0 in `data_in` is not involved in the error correction process and is left unchanged.

---

### Extraction of Original Data

After correcting any detected errors, the module extracts the original data bits by ignoring the parity and redundant bits, and selecting only the bits located at positions that are not powers of 2. These selected bits are then assembled into the output, maintaining their original order.

---

## Reset Behavior

The module does not explicitly handle reset signals as it operates combinationally on the input `data_in`.

---

## Timing Considerations

- The module is purely combinational, and the output `data_out` is updated immediately upon changes to the input `data_in`.