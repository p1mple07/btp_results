Here is the implementation of the Hebbian FSM for training a two-input logic gate in SystemVerilog:

module hebbian_gates (
    input wire clk,
    input wire rst,
    input wire [3:0] a,
    input wire [3:0] b,
    input wire [1:0] gate_select,
    output reg signed [3:0] w1,
    output reg signed [3:0] w2,
    output reg signed [3:0] bias,
    output reg signed [3:0] present_state,
    output reg signed [3:0] next_state
);

//... (code continues below)