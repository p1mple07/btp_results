`timescale 1ns/1ns

module systolic_array #(
    parameter DATA_WIDTH = 8
)
(
    input  wire                 clk,
    input  wire                 reset,
    input  wire                 load_weight,   // load the weight into the PE if high
    input  wire                 valid,         // signal to indicate new data is valid

    input  wire [DATA_WIDTH-1:0] input_in,     // input from left PE or from memory
    input  wire [DATA_WIDTH-1:0] weight,       // new weight to be loaded
    input  wire [DATA_WIDTH-1:0] psum_in,      // accumulated sum from the PE above

    output reg  [DATA_WIDTH-1:0] input_out,    // pass input to the right PE
    output reg  [DATA_WIDTH-1:0] psum_out      // pass accumulated sum downward
);

    reg                      clk_i, reset_i, load_weights_i, start_i, done_i;

    weight_stationary_pe u0(
        .clk(clk),
        .reset(reset),
        .load_weight(load_weight),
        .valid(valid),
        .input_in(input_in),
        .weight(weight),
        .psum_in(psum_in),
        .input_out(input_out),
        .psum_out(psum_out),
        .done(done_i)
    );

    weight_stationary_pe u1(
        .clk(clk),
        .reset(reset),
        .load_weight(load_weight),
        .valid(valid),
        .input_in(input_in),
        .weight(weight),
        .psum_in(psum_in),
        .input_out(input_out),
        .psum_out(psum_out),
        .done(done_i)
    );

    weight_stationary_pe u2(
        .clk(clk),
        .reset(reset),
        .load_weight(load_weight),
        .valid(valid),
        .input_in(input_in),
        .weight(weight),
        .psum_in(psum_in),
        .input_out(input_out),
        .psum_out(psum_out),
        .done(done_i)
    );

    weight_stationary_pe u3(
        .clk(clk),
        .reset(reset),
        .load_weight(load_weight),
        .valid(valid),
        .input_in(input_in),
        .weight(weight),
        .psum_in(psum_in),
        .input_out(input_out),
        .psum_out(psum_out),
        .done(done_i)
    );

    // Connect the PEs in a 2x2 systolic array
    u0.input_out  <= u1.input_in;
    u0.psum_out   <= u1.psum_out;

    u1.input_out  <= u2.input_in;
    u1.psum_out   <= u2.psum_out;

    u2.input_out  <= u3.input_in;
    u2.psum_out   <= u3.psum_out;

    u3.input_out  <= u0.input_in; // loop back for full round‑robin
    u3.psum_out   <= u0.psum_out;

    // Ensure all outputs finish after the last cycle
    u0.done = u1.done;
    u1.done = u2.done;
    u2.done = u3.done;

endmodule
