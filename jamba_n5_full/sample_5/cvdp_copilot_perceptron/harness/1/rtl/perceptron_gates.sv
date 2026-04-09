module perceptron_gates(
    input clk,
    input rst_n,
    input wire [3:0] x1, x2,
    input wire learning_rate,
    input wire threshold,
    input wire gate_select,
    output reg percep_w1, percep_w2, percep_bias,
    output reg present_addr,
    output reg stop,
    output reg input_index,
    output reg [3:0] y_in,
    output reg y,
    output reg [3:0] prev_percep_wt_1, prev_percep_wt_2, prev_percep_bias,
    output reg prev_percep_wt_2, prev_percep_bias?
);
