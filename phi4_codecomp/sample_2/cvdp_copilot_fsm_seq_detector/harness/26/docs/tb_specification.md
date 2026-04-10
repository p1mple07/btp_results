### **Testbench Specification Document for `tb_fsm_seq_detector`**

---

#### **1. Overview**

The testbench is designed to verify the functionality of a sequence detector implemented using a Finite State Machine (FSM). The FSM is expected to detect a specific sequence (`01001110`) of bits in a continuous input stream. The testbench simulates various input patterns and verifies that the FSM correctly identifies the sequence. The testbench also includes a reference logic to compare the FSM's output with the expected result.

---

#### **2. Testbench Structure**

The testbench is structured to perform the following tasks:

1. **Clock Generation**:
   - A clock signal is generated to drive the FSM and synchronize the input sequence.

2. **Reset Signal**:
   - A reset signal is applied to initialize the FSM to its initial state before the simulation begins.

3. **Input Sequence**:
   - A series of input patterns are concatenated to form a complete input sequence. This sequence is fed into the FSM one bit at a time.

4. **Reference Sequence Detection**:
   - A reference logic is implemented to independently detect the sequence in the input stream. This logic is used to verify the correctness of the FSM's output.

5. **Simulation Control**:
   - The simulation runs for a specified number of clock cycles and then terminates.

---

#### **3. Testbench Parameters**

The testbench uses the following parameters:

- **Sequence Length**: The length of the sequence to be detected (8 bits).
- **Informed Sequence**: The specific sequence of bits that the FSM is designed to detect (`01001110`).

---

#### **4. Testbench Logic**

##### **4.1 Clock Generation**
- A clock signal is generated with a fixed period. This clock signal is used to synchronize the input sequence and the FSM's operations.

##### **4.2 Reset and Input Sequence**
- The reset signal is asserted for a few clock cycles to ensure the FSM is in its initial state.
- After the reset, the input sequence is fed into the FSM one bit at a time. The sequence is constructed by concatenating multiple patterns.

##### **4.3 Reference Sequence Detector Logic Using Shift Register**
- The reference logic uses a shift register to store the last `Length` bits of the input sequence. This shift register is updated on every clock cycle by shifting in the current input bit and discarding the oldest bit.
- The shift register ensures that the reference logic always has the most recent `Length` bits of the input sequence, which are then compared with the informed sequence.

---

#### **5. Debugging and Logging**

- The testbench includes logging statements to track the simulation progress. These logs display the current state of the FSM, the input sequence, and the output signal.
- The reference sequence detection signal is also logged for comparison with the FSM's output.

---

#### **6. Waveform Dumping**

- The testbench generates a waveform file (VCD) to allow for visual inspection of the signals during the simulation.

---

#### **7. Testbench Flow**

1. **Reset Phase**:
   - The FSM is reset to its initial state.

2. **Input Sequence Phase**:
   - The input sequence is fed into the FSM one bit at a time.

3. **Reference Sequence Detection**:
   - The reference logic checks the input sequence for the informed sequence and compares its output with the FSM's output.

4. **Simulation Termination**:
   - The simulation ends after the input sequence is fully processed.

---

#### **8. Test Case Details**

##### **8.1 Test Case 1: Reset and Initialization**
- **Description**: Verify that the FSM resets correctly and initializes to the expected state.
- **Input**: Reset signal is asserted for a few clock cycles.
- **Expected Output**: The FSM should be in its initial state, and the sequence detection signal should be `0`.

##### **8.2 Test Case 2: Sequence Detection**
- **Description**: Verify that the FSM correctly detects the informed sequence in the input sequence.
- **Input**: The input sequence contains the informed sequence.
- **Expected Output**: The FSM should detect the sequence and assert the sequence detection signal when the sequence is found.

##### **8.3 Test Case 3: Multiple Sequence Detection**
- **Description**: Verify that the FSM can detect multiple occurrences of the informed sequence in the input sequence.
- **Input**: The input sequence contains multiple occurrences of the informed sequence.
- **Expected Output**: The FSM should detect each occurrence of the sequence and assert the sequence detection signal each time.

##### **8.4 Test Case 4: No Sequence Detection**
- **Description**: Verify that the FSM does not detect the sequence when the input sequence does not contain the informed sequence.
- **Input**: The input sequence does not contain the informed sequence.
- **Expected Output**: The FSM should not assert the sequence detection signal.

##### **8.5 Test Case 5: Overlapping Sequence Detection**
- **Description**: Verify that the FSM correctly handles overlapping sequences in the input stream.
- **Input**: The input sequence contains overlapping occurrences of the informed sequence.
- **Expected Output**: The FSM should detect each occurrence of the sequence, including overlapping sequences, and assert the sequence detection signal each time.

---

#### **9. Expected Output Calculation**

##### **9.1 Reference Sequence Detection pulse**
- For each test case, the expected output is calculated based on the reference sequence detection logic. The logic works as follows:
  - The reference logic compares the contents of the shift register with the informed sequence.
  - If a match is found, the reference logic asserts a signal indicating that the sequence has been detected.

##### **9.2 Reference Sequence output**
- The expected output for each test case is as follows:
  - **Test Case 1**: The sequence detection signal should be `0`.
  - **Test Case 2**: The sequence detection signal should be `1` when the sequence is detected.
  - **Test Case 3**: The sequence detection signal should be `1` for each occurrence of the sequence.
  - **Test Case 4**: The sequence detection signal should be `0`.
  - **Test Case 5**: The sequence detection signal should be `1` for each occurrence of the sequence, including overlapping sequences.

---

#### **10. Edge Cases**

- The testbench includes multiple patterns to ensure that the FSM can detect the sequence in various scenarios.
- The reference logic ensures that the FSM's output is verified against the expected result.

---

#### **11. Used Patterns**

The testbench uses the following 8-bit patterns to construct the input sequence:

- **Pattern0**: `01001110`
- **Pattern1**: `10100111`
- **Pattern2**: `01001110`
- **Pattern3**: `10011100`
- **Pattern4**: `10011100`
- **Pattern5**: `01010011`
- **Pattern6**: `10010011`
- **Pattern7**: `01111111`
- **Pattern8**: `01001110`
- **Pattern9**: `01010011`
- **Pattern10**: `01001110`

These patterns are concatenated to form the complete input sequence, which is fed into the FSM one bit at a time.

---

#### **12. Overlapping Sequence Detection**

The testbench supports testing for overlapping sequences. Overlapping sequences occur when the end of one sequence overlaps with the beginning of the next sequence. For example, if the informed sequence is `01001110`, an overlapping sequence might look like `010011101001110`. The FSM should detect both occurrences of the sequence in this case.

The reference logic is designed to handle overlapping sequences by maintaining a history of previous detections. This ensures that the FSM's output matches the expected result, even in cases where sequences overlap.

---
