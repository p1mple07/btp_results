# RTL Specification

The `cvdp_prbs_gen` module is a versatile digital component designed to function as both a PRBS (Pseudo-Random Binary Sequence) generator and checker. It is highly configurable, allowing for customization based on specific application requirements. The module operates in two distinct modes:

- **Generator Mode**: Generates a PRBS pattern using a Linear Feedback Shift Register (LFSR).
- **Checker Mode**: Checks incoming data against a locally generated PRBS pattern to detect errors.

---

### Module Overview

The module is built around the concept of Linear Feedback Shift Registers (LFSRs), which are used to produce pseudo-random sequences. By configuring the polynomial length and tap positions, the module can generate maximal-length sequences that cycle through all possible non-zero states before repeating.

---

### Key Features

- **Dual Functionality**: Can operate as either a PRBS generator or checker.
- **Configurable Parameters**:
  - **Polynomial Length (`POLY_LENGTH`)**: Determines the size of the LFSR.
  - **Polynomial Tap (`POLY_TAP`)**: Specifies the tap positions for feedback in the LFSR.
  - **Data Width (`WIDTH`)**: Sets the bit width of the input and output buses.
- **Synchronous Operation**: All activities are synchronized with the rising edge of the clock signal.
- **Synchronous Reset**: Provides a predictable reset behavior by initializing registers synchronously.

---

### Operational Modes

#### Generator Mode (`CHECK_MODE = 0`)

- **Purpose**: Generates a PRBS pattern based on the configured polynomial.
- **Behavior**:
  - Uses an LFSR to produce a pseudo-random sequence.
  - Outputs the generated PRBS pattern on the `data_out` bus.
- **Data Input**: The `data_in` bus is not used and should be tied to zero.

#### Checker Mode (`CHECK_MODE = 1`)

- **Purpose**: Checks incoming data for errors by comparing it with a locally generated PRBS pattern.
- **Behavior**:
  - Loads incoming data into the PRBS registers.
  - Generates the expected PRBS pattern internally.
  - Compares the incoming data with the expected pattern.
  - Outputs the comparison result on the `data_out` bus; non-zero values indicate errors.
- **Data Input**: The `data_in` bus receives the data to be checked.

---

### Interface Description

#### Inputs

- **`clk`**
  - **Description**: Clock signal; all operations occur on the rising edge.
- **`rst`**
  - **Description**: Synchronous reset signal, active high; initializes the module.
- **`data_in`**
  - **Width**: Configurable via `WIDTH` parameter.
  - **Description**:
    - **Generator Mode**: Unused; tied to zero.
    - **Checker Mode**: Receives the data to be compared with the PRBS pattern.

#### Outputs

- **`data_out`**
  - **Width**: Configurable via `WIDTH` parameter.
  - **Description**:
    - **Generator Mode**: Outputs the generated PRBS pattern.
    - **Checker Mode**: Outputs the error detection results; zero indicates no error.

---

### Operational Description

#### Reset Behavior

- On assertion of the synchronous reset (`rst` high):
  - The PRBS registers are initialized to all ones.
  - The `data_out` bus is set to all ones.
  - Ensures the PRBS generator starts from a known state.

#### PRBS Generation

- **LFSR Structure**:
  - Consists of a shift register of length `POLY_LENGTH`.
  - Feedback is taken by XORing the bits at positions `POLY_TAP` and `POLY_LENGTH`.
- **Sequence Generation**:
  - On each clock cycle, the feedback bit is calculated and shifted into the register.
  - The PRBS sequence cycles through all possible non-zero states before repeating.

#### Error Checking (Checker Mode)

- **Data Comparison**:
  - Incoming data from `data_in` is loaded into the PRBS registers.
  - The module generates the expected PRBS pattern internally.
  - Each bit of `data_in` is compared with the expected PRBS bit.
- **Error Detection**:
  - The result of the comparison is output on `data_out`.
  - A zero value on `data_out` indicates no errors; a non-zero value indicates discrepancies.