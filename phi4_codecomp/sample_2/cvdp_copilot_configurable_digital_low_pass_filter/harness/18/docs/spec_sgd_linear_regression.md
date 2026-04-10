# Module Documentation: `sgd_linear_regression`

## Overview

The `sgd_linear_regression` module implements a linear regression model using the **Stochastic Gradient Descent (SGD)** optimization method. The design trains a model to predict outputs `y` given input data `x`. It computes weight `w` and bias `b` updates based on the error between the predicted output and the true output.

## Features

- Parameterizable **data width** for flexibility in precision.
- Parameterizable **learning rate** to control the step size in gradient descent.
- Implements weight (`w`) and bias (`b`) updates based on gradient descent logic.
- Outputs the trained weight (`w`) and bias (`b`).

---

## Parameter List

| Parameter Name    | Default Value | Description                                      |
|-------------------|---------------|--------------------------------------------------|
| `DATA_WIDTH`      | `16`          | Width of the input, output, and internal signals.|
| `LEARNING_RATE`   | `3'd1`        | Fixed learning rate for weight and bias updates.|

---

## Port List

| Port Name           | Direction | Type                              | Description                             |
|----------------------|----------|-----------------------------------|-----------------------------------------|
| `clk`               | `input`   | `logic`                          | Clock signal for sequential operations. |
| `reset`             | `input`   | `logic`                          | Asynchronous reset signal.              |
| `x_in`              | `input`   | `logic signed [DATA_WIDTH-1:0]`  | Input data (`x`) for the linear regression. |
| `y_true`            | `input`   | `logic signed [DATA_WIDTH-1:0]`  | True output (`y`) or target value.      |
| `w_out`             | `output`  | `logic signed [DATA_WIDTH-1:0]`  | Trained weight (`w`).                   |
| `b_out`             | `output`  | `logic signed [DATA_WIDTH-1:0]`  | Trained bias (`b`).                     |

---

## Local Parameters

| Local Parameter Name | Description                                                   |
|-----------------------|---------------------------------------------------------------|
| `NBW_PRED`           | Intermediate width for predicted value (`y_pred`), defined as `2*DATA_WIDTH + 1`. |
| `NBW_ERROR`          | Bit width for error signal, defined as `NBW_PRED + 1`.         |
| `NBW_DELTA`          | Bit width for weight and bias deltas, defined as `3 + NBW_ERROR + DATA_WIDTH`. |

---

## Internal Signals

### Registers
| Signal Name  | Type                             | Description                                       |
|--------------|----------------------------------|-------------------------------------------------|
| `w`         | `logic signed [DATA_WIDTH-1:0]`  | Weight register for the linear model.            |
| `b`         | `logic signed [DATA_WIDTH-1:0]`  | Bias register for the linear model.              |

### Intermediate Values
| Signal Name   | Type                                | Description                                      |
|---------------|-------------------------------------|-------------------------------------------------|
| `y_pred`      | `logic signed [DATA_WIDTH-1:0]`    | Predicted output value.                          |
| `error`       | `logic signed [NBW_ERROR-1:0]`     | Error between true and predicted output.         |
| `delta_w`     | `logic signed [NBW_DELTA-1:0]`     | Weight update value based on gradient descent.   |
| `delta_b`     | `logic signed [NBW_DELTA-1:0]`     | Bias update value based on gradient descent.     |

---

## Functional Description

### 1. Predicted Output Calculation
The predicted output (`y_pred`) is calculated as:
```math
y_{\text{pred}} = (w \cdot x_{\text{in}}) + b
```

This computation is implemented using **combinational logic** in an `always_comb` block.

### 2. Error Calculation
The error signal (`error`) is calculated as:
```math
\text{error} = y_{\text{true}} - y_{\text{pred}}
```

This measures the difference between the true target (`y_true`) and the predicted output (`y_pred`).

### 3. Delta Updates
The weight (`delta_w`) and bias (`delta_b`) updates are computed based on the error and the learning rate:
```math
\Delta w = \text{LEARNING\_RATE} \cdot \text{error} \cdot x_{\text{in}}
```
```math
\Delta b = \text{LEARNING\_RATE} \cdot \text{error}
```

These updates are calculated combinationally.

### 4. Weight and Bias Updates
The weight (`w`) and bias (`b`) registers are updated sequentially at the rising edge of the clock (`clk`), and can be reset asynchronously using the `reset` signal:
```math
w \leftarrow w + \Delta w
```
```math
b \leftarrow b + \Delta b
```

If the `reset` signal is asserted, both `w` and `b` are reset to `0`.

---

## Sequential Behavior

| Event                      | Behavior                                                  |
|----------------------------|-----------------------------------------------------------|
| Positive Edge of `clk`     | Update `w` and `b` with their respective delta values.    |
| Asynchronous `reset`       | Reset `w` and `b` to `0`.                                 |

---

## Output Assignments

- `w_out` is directly assigned the value of `w` (trained weight).
- `b_out` is directly assigned the value of `b` (trained bias).

---

## Example Usage

### Instantiation
```verilog
sgd_linear_regression #(
    .DATA_WIDTH(16),
    .LEARNING_RATE(3'd1)
) u_sgd_linear_regression (
    .clk(clk),
    .reset(reset),
    .x_in(x_in),
    .y_true(y_true),
    .w_out(w_out),
    .b_out(b_out)
);