# Specification Document for Leading/Trailing Zero Counter

## Overview

The `cvdp_leading_zero_cnt` module is a parameterizable Verilog module designed to count the number of leading or trailing zeros in an input data word. It operates on data widths that are multiples of 4 bits (nibbles) and outputs the zero count. The counting direction—leading zeros or trailing zeros—is configurable via a parameter.

## Features

- **Configurable Data Width**: Supports input data widths (`DATA_WIDTH`) that are multiples of 4 bits.
- **Counting Direction**: Counts either leading zeros (from the most significant bit) or trailing zeros (from the least significant bit) based on the `REVERSE` parameter.

## Parameters

- `DATA_WIDTH` (default: 32)
  - Specifies the width of the input data bus `data`.
  - Must be a multiple of 4.

- `REVERSE` (default: 0)
  - Determines the zero counting direction:
    - `0`: Counts leading zeros.
    - `1`: Counts trailing zeros.

## Ports

### Input

- `data` (`input logic [DATA_WIDTH - 1 : 0]`)
  - The input data word on which the zero counting operation is performed.

### Output

- `leading_zeros` (`output logic [$clog2(DATA_WIDTH) - 1 : 0]`)
  - The count of leading or trailing zeros in the input data, depending on the `REVERSE` parameter.

## Functional Description

The `cvdp_leading_zero_cnt` module analyzes the input data word and calculates the number of consecutive zeros either from the most significant bit (leading zeros) or from the least significant bit (trailing zeros), based on the configuration.

### Operation

- **Data Segmentation**:
  - The input data is divided into 4-bit segments (nibbles) to facilitate efficient zero counting.
- **Zero Counting per Nibble**:
  - For each nibble, the module determines:
    - If the nibble is entirely zeros.
    - The number of consecutive zeros within the nibble, starting from the most significant bit (for leading zeros) or least significant bit (for trailing zeros).
- **Counting Direction**:
  - **Leading Zero Count (`REVERSE = 0`)**:
    - The module processes nibbles starting from the most significant nibble towards the least significant nibble.
    - Within each nibble, it counts zeros starting from the most significant bit.
  - **Trailing Zero Count (`REVERSE = 1`)**:
    - The module processes nibbles starting from the least significant nibble towards the most significant nibble.
    - Within each nibble, it counts zeros starting from the least significant bit.
- **Determining the First Non-Zero Nibble**:
  - The module identifies the position of the first nibble that is not entirely zeros.
- **Calculating the Total Zero Count**:
  - The total zero count is calculated by combining:
    - The number of zeros from complete zero nibbles before the first non-zero nibble.
    - The number of consecutive zeros within the first non-zero nibble.
- **Output Assignment**:
  - The final zero count is provided on the `leading_zeros` output port.
