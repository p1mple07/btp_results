
# Multiplexer Specification Document

## Introduction

The **Multiplexer** module is a configurable data selector that chooses one of the multiple input data lines based on a selection signal. It supports configurable data width, input count, optional registered output, and default output handling when an invalid selection is made.

---

## Functional Overview

The multiplexer operates based on the following conditions:

1. **Selection Logic:**  
   - The `sel` input selects one of the `NUM_INPUTS` input data lines.
   - If `HAS_DEFAULT` is enabled and `sel` is out of range, the output is set to `DEFAULT_VALUE`.

2. **Bypass Mode:**  
   - If the `bypass` signal is active, the multiplexer forces `out` to always select `inp_array[0]`.

3. **Registering Output:**  
   - If `REGISTER_OUTPUT` is enabled, the output data is registered using `clk` and `rst_n`.
   - If `REGISTER_OUTPUT` is disabled, the output is purely combinational.

---

## Module Interface

The multiplexer module should be defined as follows:

