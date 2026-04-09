rtl/perceptron_gates.sv
------------------------------------------------------------
module perceptron_gates (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic signed [3:0]     x1,
    input  logic signed [3:0]     x2,
    input  logic                  learning_rate,
    input  logic signed [3:0]     threshold,
    input  logic [1:0]            gate_select,
    output logic signed [3:0]     percep_w1,
    output logic signed [3:0]     percep_w2,
    output logic signed [3:0]     percep_bias,
    output logic [3:0]            present_addr,
    output logic                  stop,
    output logic [2:0]            input_index,
    output logic signed [3:0]     y_in,
    output logic signed [3:0]     y,
    output logic signed [3:0]     prev_percep_w1,
    output logic signed [3:0]     prev_percep_w2,
    output logic signed [3:0]     prev_percep_bias
);

  //-------------------------------------------------------------------------
  // Internal registers and wires
  //-------------------------------------------------------------------------
  // Microcode state register (6 states: 0..5)
  logic [3:0] present_addr;
  
  // Perceptron current weights and bias
  logic signed [3:0] percep_w1, percep_w2, percep_bias;
  
  // Previous iteration weights and bias (for convergence check)
  logic signed [3:0