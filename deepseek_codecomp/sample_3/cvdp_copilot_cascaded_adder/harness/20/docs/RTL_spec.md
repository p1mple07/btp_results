# Functional Specification Document

## Module Name: `cascaded_adder`

### Overview

The `cascaded_adder` module is a parameterized adder tree that sums multiple input data elements. Each stage of the adder can be configured as either a registered or combinational stage, determined by a control parameter (`REG`). The module produces the cumulative sum of input data elements and provides a valid output signal to indicate when the sum is ready.

### Parameters

- `IN_DATA_WIDTH` (integer): Bit width of each individual input data element.
- `IN_DATA_NS` (integer): Number of input data elements.
- `REG` (bit vector of `IN_DATA_NS` width): Control bits for each stage in the adder tree; a `1` enables a registered (clocked) stage, and a `0` enables a combinational stage.

### I/O Ports

- **Inputs:**
  - `clk`: Clock signal for synchronous operations.
  - `rst_n`: Active-low reset signal.
  - `i_valid`: Indicates when the input data is valid.
  - `i_data`: Flattened input data array containing `IN_DATA_NS` data elements, each of width `IN_DATA_WIDTH` bits.

- **Outputs:**
  - `o_valid`: Indicates when the output data (`o_data`) is valid.
  - `o_data`: Sum of all input data elements, with width adjusted to prevent overflow.

### Functionality

1. **Data Input and Latching:**
   - Upon receiving a valid input signal (`i_valid`), the input data array is latched to enable summation processing. The flattened input data is converted into an internal array for accessibility by each stage in the adder tree.

2. **Adder Tree Logic:**
   - The adder tree consists of multiple stages, each configurable as either a registered or combinational stage, based on the `REG` parameter.
   - **Stage Operation**:
     - If configured as a registered stage, the stage accumulates the sum of the current data element and the previous stage's result synchronously on the clock.
     - If configured as a combinational stage, the stage performs the addition immediately without waiting for a clock edge.
     - Note: The first stage of the adder tree is a pass-through without performing any calculation. This is reflected in both registered and combinational configurations for the first stage.
   - The adder tree thus produces the cumulative sum in a sequential manner, with data propagated through each stage until the final sum is calculated.

3. **Valid Signal Propagation:**
   - The `i_valid` signal is latched similarly to the input data and assigned to a shift register.
   - This valid signal shift register mirrors the configuration of the adder tree, where each stage can be either registered or combinational based on the `REG` parameter.
   - The final valid output, `o_valid`, reflects the valid state of the cumulative sum in the final stage, ensuring synchronization with `o_data`.

4. **Output Assignment:**
   - The cumulative sum from the final adder stage is output on `o_data`, and `o_valid` is asserted when the sum is ready, indicating valid data at the output.

### Timing and Latency

- **Combinational and Registered Stages:** 
  - The `REG` parameter controls whether each stage in the adder tree is registered or combinational. Registered stages add a clock-cycle latency per stage, while combinational stages provide immediate results without clock delay.
- **Critical Path Delay and Latency Calculation:** 
  - The overall delay is determined by the total combinational delay across the stages and the clock-cycle latency of the registered stages. The timing of `o_valid` aligns with the availability of the final sum in `o_data`.

### Reset Behavior

- When `rst_n` is low, all internal registers are reset to zero, ensuring a known state before data processing begins.

### Key Points

- The `cascaded_adder` module is highly configurable, with flexible control over each stage’s timing behavior.
- Valid signal propagation is synchronized with data latching, ensuring correct timing and valid output indication.
- The final output signals, `o_data` and `o_valid`, provide the cumulative sum and its validity, respectively, upon completion of all adder stages.