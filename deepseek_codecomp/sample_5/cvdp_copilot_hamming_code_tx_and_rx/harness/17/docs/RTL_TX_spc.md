# Hamming Code Transmitter Module (`hamming_tx`)

## Overview
The `hamming_tx` module is a parameterized Hamming code transmitter that encodes input data (`data_in`) with parity bits for single-bit error detection and correction. The design allows users to configure the number of data and parity bits, automatically calculating the total encoded output size.

## Features
- Configurable input data width (`DATA_WIDTH`) and parity bit count (`PARITY_BIT`).
- Encoded output includes data bits, parity bits, and a redundant bit to meet the Hamming code requirements.
- Even parity logic is used to compute parity bits dynamically based on the input configuration.
- Placement of parity bits at positions corresponding to powers of 2 in the encoded word.

## Parameters

| Parameter Name      | Default Value                | Description                                                                           |
|---------------------|------------------------------|---------------------------------------------------------------------------------------|
| `DATA_WIDTH`        | 4                            | Specifies the width of the data input.                                                |
| `PARITY_BIT`        | 3                            | Specifies the number of parity bits. Minimum integer that satisfies the hamming code formula 2^p >= (p + m) + 1,  where `p` is the number of parity bits and `m` is the width of the data                                               |
| `ENCODED_DATA`      | `PARITY_BIT + DATA_WIDTH + 1`| Total width of the encoded output word, including parity and data bits.              |
| `ENCODED_DATA_BIT`  | `$clog2(ENCODED_DATA)`       | Bit-width required to represent indices of the encoded word.                         |

## Ports

| Port Name  | Direction | Width               | Description                                                             |
|------------|-----------|---------------------|-------------------------------------------------------------------------|
| `data_in`  | Input     | `DATA_WIDTH`        | Input data word to be encoded.                                          |
| `data_out` | Output    | `ENCODED_DATA`      | Encoded output word with parity, data bits, and a redundant bit.        |

## Behavioral Specification

1. **Initialization**:
   - Clear all internal registers and the output (`data_out`).

2. **Data Bit Placement**:
   - Input data bits are mapped sequentially from least significant bit (LSB) to most significant bit (MSB) into positions in `data_out` that are **not powers of 2**.

3. **Parity Bit Calculation**:
   - For each parity bit (nth parity bit, where n ranges from 0 to PARITY_BIT-1), determine its value by calculating even parity on the bits in `data_out` located at indices where the nth bit (counting from the least significant bit) of the binary index is 1

4. **Parity Bit Placement**:
   - Insert the calculated parity bits into `data_out` at positions corresponding to powers of 2.

5. **Redundant Bit**:
   - The least significant bit (`data_out[0]`) is a redundant bit and is always set to `1'b0`.

## Timing and Synchronization

- The `hamming_tx` module uses **combinational logic**. The encoded output is generated immediately after the input is applied.

## Constraints

1. **Input Size Validation**:
   - It is assumed that the size of `data_in` matches the specified `DATA_WIDTH`.

2. **Parity Bit Validation**:
   - Users are responsible for ensuring that `PARITY_BIT` satisfies the Hamming code formula:2^p >= (p + m) + 1, where `p` is the number of parity bits and `m` is the width of the data.