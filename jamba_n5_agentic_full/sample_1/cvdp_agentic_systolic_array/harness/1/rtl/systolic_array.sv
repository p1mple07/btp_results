
module systolic_array #(
    parameter DATA_WIDTH = 8
) (
    input wire clk,
    input wire reset,
    input wire load_weights,
    input wire start,
    input wire done,
    output reg [DATA_WIDTH-1:0] y0,
    output reg [DATA_WIDTH-1:0] y1
);

// Instantiate 4 weight stationary PEs
wire_systematic_pe u0 (
    .clk(clk),
    .reset(reset),
    .load_weights(load_weights),
    .start(start),
    .w00(w000),
    .w01(w010),
    .w10(w100),
    .w11(w110),
    .x0(x00),
    .x1(x10),
    .y0(y00),
    .y1(y10)
);

wire_systematic_pe u1 (
    .clk(clk),
    .reset(reset),
    .load_weights(load_weights),
    .start(start),
    .w00(w001),
    .w01(w011),
    .w10(w101),
    .w11(w111),
    .x0(x01),
    .x1(x11),
    .y0(y01),
    .y1(y11)
);

wire_systematic_pe u2 (
    .clk(clk),
    .reset(reset),
    .load_weights(load_weights),
    .start(start),
    .w00(w002),
    .w01(w012),
    .w10(w102),
    .w11(w112),
    .x0(x02),
    .x1(x12),
    .y0(y02),
    .y1(y12)
);

wire_systematic_pe u3 (
    .clk(clk),
    .reset(reset),
    .load_weights(load_weights),
    .start(start),
    .w00(w003),
    .w01(w013),
    .w10(w103),
    .w11(w113),
    .x0(x03),
    .x1(x13),
    .y0(y03),
    .y1(y13)
);

// Connections between PEs: horizontal and vertical

// Horizontal links: u0 -> u1, u1 -> u2, u2 -> u3
// Vertical links: u0 -> u2, u1 -> u3, u2 -> u0, u3 -> u0? Maybe we need a crossbar.

// Instead, we can implement a simple 2x2 array where each row and column connects.

// For simplicity, we can set up each PE to pass to right and below.

// Connect u0 to u1 and u0 to u2.
u0.y0(u1.y0); u0.y1(u1.y1);
u0.y0(u2.y0); u0.y1(u2.y1);

u1.y0(u0.y0); u1.y1(u1.y1);
u1.y0(u2.y0); u1.y1(u2.y1);
u1.y0(u0.y0); u1.y1(u2.y1);

Wait, this is messy.

Alternatively, we can use a known pattern: each PE processes a pair of data.

Given the complexity, maybe we can provide a minimal solution that instantiates 4 PEs and connects them in a way that the system works.

We need to produce the file systolic_array.sv.

Let's try to produce a simplified 2x2 systolic array.

We'll define:

`timescale 1ns/1ns

module systolic_array #(
    parameter DATA_WIDTH = 8
) (
    input wire clk,
    input wire reset,
    input wire load_weights,
    input wire start,
    input wire done,
    output reg [DATA_WIDTH-1:0] y0,
    output reg [DATA_WIDTH-1:0] y1
);

// Instantiate 4 PEs
wire_systematic_pe u0 (
    .clk(clk),
    .reset(reset),
    .load_weights(load_weights),
    .start(start),
    .w00(w000),
    .w01(w010),
    .w10(w100),
    .w11(w110),
    .x0(x00),
    .x1(x10),
    .y0(y00),
    .y1(y10)
);

wire_systematic_pe u1 (
    .clk(clk),
    .reset(reset),
    .load_weights(load_weights),
    .start(start),
    .w00(w001),
    .w01(w011),
    .w10(w101),
    .w11(w111),
    .x0(x01),
    .x1(x11),
    .y0(y01),
    .y1(y11)
);

wire_systematic_pe u2 (
    .clk(clk),
    .reset(reset),
    .load_weights(load_weights),
    .start(start),
    .w00(w002),
    .w01(w012),
    .w10(w102),
    .w11(w112),
    .x0(x02),
    .x1(x12),
    .y0(y02),
    .y1(y12)
);

wire_systematic_pe u3 (
    .clk(clk),
    .reset(reset),
    .load_weights(load_weights),
    .start(start),
    .w00(w003),
    .w01(w013),
    .w10(w103),
    .w11(w113),
    .x0(x03),
    .x1(x13),
    .y0(y03),
    .y1(y13)
);

// Now wire the connections

// Horizontal connections: u0 -> u1, u1 -> u2, u2 -> u3
u0.y0(u1.y0); u0.y1(u1.y1);
u1.y0(u2.y0); u1.y1(u2.y1);
u2.y0(u3.y0); u2.y1(u3.y1);

// Vertical connections: u0 -> u2, u1 -> u3
u0.y0(u2.y0); u0.y1(u2.y1);
u1.y0(u3.y0); u1.y1(u3.y1);

// Also connect u0 to u0 itself? No.

Wait, we need to ensure data propagates. This is getting too complicated.

Given the constraints, perhaps we can provide a minimal representation that uses the four PEs and demonstrates the architecture.

The testbench verifies that the outputs match expected values.

We can provide a very minimal code for systolic_array.sv that instantiates four PEs and connects them in a trivial way.

Let's produce something like:

