# Test Plan for `qam16_mapper_interpolated` Testbench Verification

## Overview

This test plan describes a structured approach to verify the functionality of the `qam16_mapper_interpolated` module using the `tb_qam16_mapper_interpolated` testbench. The primary goal is to ensure the module correctly maps input symbols to interpolated in-phase (I) and quadrature (Q) outputs across all valid configurations of the parameter `N`.

---

## Test Objectives

1. **Functional Correctness**: Confirm that the module produces accurate in-phase and quadrature outputs for all valid input combinations.
2. **Boundary Validation**: Validate the handling of edge cases, such as extreme input values and alternating patterns.
3. **Comprehensive Coverage**: Achieve complete coverage for all combinations of inputs, ensuring robustness.
4. **Scalability**: Assess module performance and functionality for varying values of the parameter `N`.
5. **Comparison and Validation**: Verify that the DUT outputs match the Golden Model results, log any mismatches, and maintain a count of passed and failed tests.

---

## Module Description

### Module Name: `qam16_mapper_interpolated`

### Parameters

- **`N`**: Number of input symbols (varies during testing).
- **`IN_WIDTH`**: Fixed at `4`, representing the bit width of each input symbol.
- **`OUT_WIDTH`**: Fixed at `3`, representing the bit width of each output value.

### Ports

- **Inputs**:
  - Concatenated binary symbols, representing multiple input data values.
- **Outputs**:
  - Interpolated in-phase (`I`) and quadrature (`Q`) components, corresponding to processed input symbols.

---

## Test Methodology

### Functional Components

1. **Input Application**:
   - Generates and applies input stimuli to the module.
   - Converts individual input symbols into the appropriate concatenated binary format required by the DUT.
   - Handles systematic input generation for directed, edge case, and random tests.
   - Ensures input stability and synchronization with the DUT processing time.

2. **Reference Model (Golden Model)**:
   - Mimics the module's expected behavior using a high-level mathematical or algorithmic approach.
   - Maps binary input symbols to their corresponding in-phase and quadrature values based on the specification.
   - Computes interpolated values between pairs of mapped symbols to emulate the DUT's interpolation logic.
   - Produces expected outputs (`model_I`, `model_Q`) for comparison with DUT results.

3. **Output Verification**:
   - Compares the DUT outputs to the expected values (`model_I` and `model_Q`) computed by the Golden Model.
   - For each output component:
     - Checks if the DUT output matches the expected value.
     - Logs any mismatches, showing the DUT output, the expected value, and the specific index.
   - Maintains a count of:
     - **Total tests** executed.
     - **Passed tests** where all outputs matched the expected values.
     - **Failed tests** where mismatches occurred.
   - Provides a summary of the test results after execution, highlighting errors for debugging.

---

## Test Strategy

### 1. Directed Testing

**Objective**: Validate the basic functionality of mapping and interpolation using manually selected inputs.

**Steps**:
- Apply specific input patterns using the input application function.
- Compute expected outputs using the reference model.
- Compare module outputs to the expected values using the verification function.

**Test Cases**:
- Predetermined patterns, such as:
  - Uniform input values (e.g., all zeros or all maximum values).
  - Alternating patterns of 0s and 1s.

**Expected Results**:
- Outputs should match expected in-phase and quadrature values.

---

### 2. Edge Case Testing

**Objective**: Assess the module's robustness under boundary conditions.

**Steps**:
- Test inputs with:
  - Minimum possible values for all symbols.
  - Maximum possible values for all symbols.
  - Alternating maximum and minimum values.
- Generate expected results using the reference model.
- Verify outputs using the verification function.

**Expected Results**:
- Correct handling of extreme values without overflow or unexpected behavior.
- Outputs should remain within the expected range.

---

### 3. Exhaustive Testing

**Objective**: Verify all possible combinations of input symbols for a fixed `N`.

**Steps**:
- Generate all possible combinations of input values for a given number of symbols.
- Apply each combination using the input application function.
- Compute expected outputs using the reference model.
- Validate DUT outputs against reference values using the verification function.

**Expected Results**:
- 100% functional coverage for a fixed value of `N`.

---

### 4. Parameterized Testing

**Objective**: Evaluate the module's scalability by varying `N`.

**Steps**:
- Test with multiple values of `N`, such as `2`, `4`, `8`.
- For each value of `N`, repeat directed, edge case, and exhaustive testing steps.
- Use the same reference model and verification function for all configurations.

**Expected Results**:
- Consistent and correct operation across varying values of `N`.
- No degradation in performance or accuracy for larger values of `N`.

---

### 5. Golden Model Verification

**Objective**: Ensure the module produces results that match a mathematically accurate reference.

**Steps**:
1. Apply inputs using the input application function.
2. Compute expected outputs (`model_I`, `model_Q`) using the reference model.
3. Compare the DUT outputs to the expected values:
   - Log any mismatches with the following details:
     - Index of the mismatch.
     - DUT output value.
     - Expected output value.
   - Count the total tests, passed tests, and failed tests.
4. Summarize the test results after all cases are executed.

**Expected Results**:
- The DUT outputs must match the Golden Model outputs for all test cases.
- Any differences must be logged for debugging and analysis.

---

## Reporting and Analysis

- **Test Logs**:
  - Record inputs, expected outputs, actual outputs, and pass/fail status for each test case.
  - Include detailed information on any mismatches for debugging.
- **Summary Report**:
  - Total number of tests conducted.
  - Count of passed and failed tests.
  - Description of failure patterns, if any.

---

## Conclusion

This test plan provides a detailed, systematic approach to verify the `qam16_mapper_interpolated` module. By combining robust input application, accurate reference modeling, and thorough output verification, it ensures high confidence in the module's correctness and scalability. The inclusion of detailed mismatch reporting and result tracking facilitates debugging and validation.