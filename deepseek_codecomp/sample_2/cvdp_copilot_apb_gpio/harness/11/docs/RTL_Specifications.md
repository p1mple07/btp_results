---

# **Specification Document: APB GPIO Module**

## **Overview**
The APB GPIO Module (`cvdp_copilot_apb_gpio`) is a configurable general-purpose input/output (GPIO) controller designed to interface with the Advanced Peripheral Bus (APB) protocol. This module supports bidirectional GPIO control, power management, and interrupt handling, making it ideal for flexible and low-power applications.

---

## **Features**
1. **APB Protocol Compliance**:
   - Supports APB-compatible read and write transactions.
   - Implements `psel`, `penable`, `pwrite`, `paddr`, and `pwdata` signals for seamless APB integration.

2. **Bidirectional GPIOs**:
   - Each GPIO pin can be dynamically configured as input or output using the **Direction Control Register**.
   - Outputs are tristated when configured as inputs or during power-down mode.

3. **Power Management**:
   - A **Power Down Register** allows clock gating and logic disablement for reduced power consumption.
   - GPIO outputs are automatically tristated during power-down mode.

4. **Interrupt Handling**:
   - Supports edge-sensitive and level-sensitive interrupts.
   - Configurable polarity for active-high or active-low interrupts.
   - Includes a **Software-Controlled Reset** feature for interrupt clearing.

5. **Configurable Parameters**:
   - Default GPIO width (`GPIO_WIDTH`) is parameterized, allowing customization during instantiation.

---

## **APB Protocol Integration**
The module operates in two phases:
1. **Setup Phase**:
   - Configure `psel`, `paddr`, and `pwrite` signals.
2. **Access Phase**:
   - Assert `penable` for data transfer.

### **Assumptions**:
- `pready` is always high, indicating zero wait states.
- `pslverr` is always low, indicating no error responses.

---

## **Register Map**

| Address  | Register Name              | Access | Description                                                 |
|----------|----------------------------|--------|-------------------------------------------------------------|
| 0x00     | **Input Data Register**     | Read   | Reflects synchronized input states of GPIO pins.            |
| 0x04     | **Data Output Register**    | Write  | Controls GPIO output states.                                |
| 0x08     | **Output Enable Register**  | Write  | Legacy output enable control (optional).                    |
| 0x0C     | **Interrupt Enable**        | Write  | Enables/disables interrupts for GPIO pins.                  |
| 0x10     | **Interrupt Type**          | Write  | Configures edge-sensitive or level-sensitive interrupts.     |
| 0x14     | **Interrupt Polarity**      | Write  | Configures active-high or active-low interrupt behavior.     |
| 0x18     | **Interrupt State**         | Read   | Reflects the current interrupt status for GPIO pins.        |
| 0x1C     | **Direction Control**       | Write  | Configures each GPIO pin as input (`0`) or output (`1`).     |
| 0x20     | **Power Down Register**     | Write  | Controls module power state (active or power-down).          |
| 0x24     | **Interrupt Control**       | Write  | Software-controlled interrupt reset.                        |

---

## **I/O Signal Interface**

### **Inputs**:
| Signal       | Width      | Description                                     |
|--------------|------------|-------------------------------------------------|
| `pclk`       | 1          | Clock signal for synchronous operations.        |
| `preset_n`   | 1          | Active-low reset signal.                        |
| `psel`       | 1          | Select signal for the APB peripheral.           |
| `paddr[7:2]` | 6          | Address bus for register access.                |
| `penable`    | 1          | Enable signal for APB transactions.             |
| `pwrite`     | 1          | Write control signal.                           |
| `pwdata[31:0]` | 32       | Write data for APB transactions.                |
| `gpio`       | GPIO_WIDTH | Bidirectional GPIO pins (input/output signals). |

### **Outputs**:
| Signal        | Width      | Description                                     |
|---------------|------------|-------------------------------------------------|
| `prdata[31:0]`| 32         | Read data bus for APB transactions.             |
| `pready`      | 1          | Ready signal indicating valid APB access.       |
| `pslverr`     | 1          | Error signal (always low).                      |
| `gpio_int`    | GPIO_WIDTH | Individual interrupt outputs for GPIO pins.     |
| `comb_int`    | 1          | Combined interrupt signal (logical OR of all).  |

---

## **Behavioral Specifications**

1. **Clocking and Reset**:
   - Operates on the rising edge of `pclk`.
   - Asynchronous reset (`preset_n`) initializes all internal registers to zero.

2. **Bidirectional GPIOs**:
   - Configured via the **Direction Control Register (0x1C)**.
   - Outputs are tristated when set as inputs or during power-down mode.

3. **Power Management**:
   - Controlled by the **Power Down Register (0x20)**.
   - Disables internal logic and tristates outputs during power-down.

4. **Interrupts**:
   - Configurable via **Interrupt Enable (0x0C)**, **Type (0x10)**, and **Polarity (0x14)** registers.
   - Edge-sensitive interrupts detect rising edges of the input signal.
   - Level-sensitive interrupts reflect sustained input states.

5. **Software-Controlled Reset**:
   - Writing to **Interrupt Control (0x24)** clears all active interrupts.

---

## **Testing Guidelines**

### **Test Cases**:
1. **GPIO Functionality**:
   - Verify bidirectional behavior based on direction control settings.
   - Test data propagation for input and output configurations.

2. **Interrupt Management**:
   - Validate edge-sensitive and level-sensitive interrupts.
   - Test interrupt polarity for active-high and active-low configurations.
   - Confirm software-controlled interrupt reset functionality.

3. **Power Management**:
   - Ensure GPIO outputs are tristated during power-down.
   - Validate that register states persist across power-down and power-up transitions.

4. **APB Transactions**:
   - Test read/write functionality for all registers.
   - Ensure timing aligns with the APB protocol.

5. **Edge Cases**:
   - Test simultaneous interrupts across multiple GPIO pins.
   - Verify behavior for invalid APB addresses.

---

## **Limitations**
- The design assumes zero wait states (`pready = 1`) and no error conditions (`pslverr = 0`).
- Power-down mode only tristates outputs but does not isolate other signals.

---

## **References**
- AMBA APB Protocol Specification.