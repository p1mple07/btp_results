rtl/hebb_gates.sv
------------------------------------------------------------
`timescale 1ns/1ps
// Module: hebbian_rule
// Description: Implements a Moore FSM that trains a Hebbian learning model.
//              It captures two signed 4‐bit inputs (a and b), selects a target
//              based on a 2‐bit gate_select (AND, OR, NAND, NOR), computes weight
//              and bias updates, and cycles through training iterations.
module hebbian_rule (
    input  logic         clk,
    input  logic         rst,      // asynchronous active low reset
    input  logic         start,    // active high signal to start training
    input  logic signed  [3:0] a,
    input  logic signed  [3:0] b,
    input  logic  [1:0]  gate_select,
    output logic signed  [3:0] w1,
    output logic signed  [3:0] w2,
    output logic signed  [3:0] bias,
    output logic  [3:0]  present_state,
    output logic  [3:0]  next_state
);

    // FSM state definitions (total 11 states: 0 to 10)
    localparam STATE_0  = 4'd0;
    localparam STATE_1  = 4'd1;
    localparam STATE_2  = 4'd2;
    localparam STATE_3  = 4'd3;
    localparam STATE_4  = 4'd4;
    localparam STATE_5  = 4'd5;
    localparam STATE_6  = 4'd6;
    localparam STATE_7  = 4'd7;
    localparam STATE_8  = 4'd8;
    localparam STATE_9  = 4'd9;
    localparam STATE_10 = 4'd10;
    // Maximum number of training iterations (example value)
    localparam MAX_ITER = 4;

    // Internal registers
    reg [3:0] state;       // current FSM state
    reg [3:0] iter;        // training iteration counter
    reg signed [3:0] x1, x2;  // registers to hold captured inputs
    reg signed [3:0] target;  // target output determined by gate_select
    reg signed [3:0] delta_w1, delta_w2, delta_b; // computed deltas
    reg signed [3:0] w1_reg, w2_reg, bias_reg;     // weights and bias

    // Connect internal registers to outputs
    assign w1      = w1_reg;
    assign w2      = w2_reg;
    assign bias    = bias_reg;
    assign present_state = state;

    // Combinational next state logic
    wire [3:0] next_state_comb;
    assign next_state = next_state_comb;

    always_comb begin
        case(state)
            STATE_0:  next_state_comb = (start) ? STATE_1 : STATE_0;
            STATE_1:  next_state_comb = STATE_2;
            STATE_2:  next_state_comb = STATE_3;
            STATE_3:  next_state_comb = STATE_4;
            STATE_4:  next_state_comb = STATE_5;
            STATE_5:  next_state_comb = STATE_6;
            STATE_6:  next_state_comb = STATE_7;
            STATE_7:  next_state_comb = STATE_8;
            STATE_8:  next_state_comb = STATE_9;
            STATE_9:  next_state_comb = (iter < MAX_ITER) ? STATE_1 : STATE_10;
            STATE_10: next_state_comb = STATE_0;