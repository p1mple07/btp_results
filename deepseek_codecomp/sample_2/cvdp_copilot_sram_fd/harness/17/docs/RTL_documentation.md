# RTL Specification Document

This document provides the RTL specification for the module `cvdp_sram_fd`, which implements a full-duplex SRAM (Static Random Access Memory) with two separate ports: Port A and Port B. The module supports simultaneous read and write operations on both ports under specific operational constraints.

---

### Overview

The `cvdp_sram_fd` module is a synchronous memory block designed for applications requiring dual-port access to SRAM. It operates on the rising edge of a clock signal and includes a chip enable (`ce`) signal to control its active state. Each port has independent control signals for reading and writing, allowing for flexible memory operations.

---

### Module Parameters

- **`DATA_WIDTH`** (default: 8)
  - Defines the width of the data bus for both ports.
- **`ADDR_WIDTH`** (default: 4)
  - Defines the width of the address bus for both ports.
- **Derived Parameter: `RAM_DEPTH`**
  - Determines the depth of the memory array.

---

### Port Descriptions

#### Clock and Control Signals

- **`input clk`**
  - Clock signal; the module operates on the rising edge.
- **`input ce`**
  - Active-high chip enable signal.
  - **When low**: No operations are performed; outputs `a_rdata` and `b_rdata` are set to zero.
  - **When high**: The module operates normally.

#### Port A Signals

- **`input a_we`**
  - Active-high write enable for Port A.
- **`input a_oe`**
  - Active-high output (read) enable for Port A.
- **`input [ADDR_WIDTH-1:0] a_addr`**
  - Address bus for Port A.
- **`input [DATA_WIDTH-1:0] a_wdata`**
  - Write data bus for Port A.
- **`output logic [DATA_WIDTH-1:0] a_rdata`**
  - Read data output for Port A.

#### Port B Signals

- **`input b_we`**
  - Active-high write enable for Port B.
- **`input b_oe`**
  - Active-high output (read) enable for Port B.
- **`input [ADDR_WIDTH-1:0] b_addr`**
  - Address bus for Port B.
- **`input [DATA_WIDTH-1:0] b_wdata`**
  - Write data bus for Port B.
- **`output logic [DATA_WIDTH-1:0] b_rdata`**
  - Read data output for Port B.

---

### Internal Memory Array

- **`mem`**
  - An internal memory array with depth `RAM_DEPTH` and width `DATA_WIDTH`.
  - Implemented as `mem[0:RAM_DEPTH-1]`, where each location stores `DATA_WIDTH` bits.

---

### Operational Behavior

#### Clock Behavior

- The module operates on the **positive edge** of the clock signal `clk`.
- All input signals are sampled on the rising edge of `clk`.

#### Chip Enable (`ce`)

- **`ce` Low**:
  - The module ignores all inputs.
  - No read or write operations are performed.
  - Outputs `a_rdata` and `b_rdata` are set to zero.
- **`ce` High**:
  - The module performs operations based on the control signals for each port.

#### Port A Operations

- **Write Operation**
  - **Conditions**: `ce` is high, `a_we` is high.
  - **Action**: Data from `a_wdata` is written to `mem[a_addr]`.
  - **Timing**: Write latency of 1 clock cycle.
- **Read Operation**
  - **Conditions**: `ce` is high, `a_we` is low, `a_oe` is high.
  - **Action**: Data from `mem[a_addr]` is loaded into `a_rdata`.
  - **Timing**: Read latency of 1 clock cycle.
- **Priority**
  - If both read and write are enabled on Port A, the **Read operation takes precedence** over the write operation, where data previously stored at the address appears on the output while the input data is being stored in memory.

#### Port B Operations

- Port B functions identically to Port A, with corresponding signals:
  - **Write Enable**: `b_we`
  - **Output Enable**: `b_oe`
  - **Address**: `b_addr`
  - **Write Data**: `b_wdata`
  - **Read Data Output**: `b_rdata`

#### Simultaneous Access Handling

- The module supports simultaneous operations on both ports, including:
  - **Reads on both ports**.
  - **Writes on both ports**.
  - **A read on one port and a write on the other**.
- **Same Address Access**
  - If both ports access the **same address**:
    - A **"read-first" approach** is followed.
    - If a read and a write occur simultaneously at the same address, the read operation is performed before the write updates the memory.
  - **Note**: Simultaneous write accesses to the same address on both ports are **not handled**.

---

### Assumptions and Constraints

- **Synchronous Inputs**: All inputs are synchronous and sampled on the rising edge of `clk`.
- **Valid Address Range**: Input addresses `a_addr` and `b_addr` are within `0` to `RAM_DEPTH - 1`.
- **Valid Data Inputs**: Data inputs `a_wdata` and `b_wdata` are valid when `a_we` and `b_we` are high, respectively.
- **Maintaining Output State**: If neither read nor write is enabled for a port (with `ce` high), the port maintains its previous output state.
- **Data and Address Widths**: `DATA_WIDTH` and `ADDR_WIDTH` must be positive integers greater than zero.
---

### Conclusion

The `cvdp_sram_fd` module provides a robust solution for applications requiring simultaneous read and write operations on a dual-port SRAM. By adhering to the specified control signals and operational behaviors, designers can integrate this module to achieve efficient memory access with configurable data and address widths.