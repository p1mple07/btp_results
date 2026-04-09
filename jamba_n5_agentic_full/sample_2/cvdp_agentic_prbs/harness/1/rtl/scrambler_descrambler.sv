module scrambler_descrambler #(
    parameter POLY_LENGTH = 31,
    parameter POLY_TAP = 3,
    parameter WIDTH = 16,
    parameter CHECK_MODE = 0
)(
    input clk,
    input rst,
    input bypass_scrambling,
    input data_in,
    output data_out,
    output valid_out,
    output bit_count
);

// Instantiate the prbs_gen_check module
prbs_gen_check #(
    .CHECK_MODE(CHECK_MODE),
    .POLY_LENGTH(POLY_LENGTH),
    .POLY_TAP(POLY_TAP),
    .WIDTH(WIDTH)
) uut (.clk(clk), .rst(rst), .data_in(data_in), .data_out(data_out), .valid_out(valid_out));

// Counters
localparam bit_count_inc = WIDTH;
reg [bit_count_inc - 1:0] bit_count;

always @(posedge clk) begin
    if (rst) begin
        bit_count <= 0;
    end else begin
        if (valid_out) begin
            bit_count <= bit_count + 1;
        end
    end
end

assign data_out = bypass_scrambling ? data_in : ud((data_in[WIDTH-1:0]) ^ ud((u32[WIDTH-1:0]) ^ (prbs_reg[WIDTH-1:0])));

Wait, this is getting messy.

We need to use the prbs_gen_check instance to get the prbs sequence.

Let's rewrite the code more cleanly.

We'll use the prbs_gen_check instance. For generator mode, data_out is the PRBS. For checker mode, we compare data_in with expected PRBS and set data_out to 1 if mismatch.

But we also need to handle bypass_scrambling and valid_in.

Given the time, I'll produce a simplified version but ensuring the key features.

Here's a possible approach:

We'll use a state machine with a counter for bit_count.

We'll instantiate prbs_gen_check.

We'll have a port for bypass_scrambling.

We'll set up the logic.

Let's produce the code:

module scrambler_descrambler #(
    parameter POLY_LENGTH = 31,
    parameter POLY_TAP = 3,
    parameter WIDTH = 16,
    parameter CHECK_MODE = 0
)(
    input clk,
    input rst,
    input bypass_scrambling,
    input data_in,
    output data_out,
    output valid_out,
    output bit_count
);

wire [WIDTH-1:0] prbs;

prbs_gen_check #(
    .CHECK_MODE(CHECK_MODE),
    .POLY_LENGTH(POLY_LENGTH),
    .POLY_TAP(POLY_TAP),
    .WIDTH(WIDTH)
) uut (.clk(clk), .rst(rst), .data_in(data_in), .data_out(data_out), .valid_out(valid_out));

assign data_out = ud(data_in ^ prbs);

assign valid_out = valid_in && (data_in[WIDTH-1:0] == data_out);

bit_count = bit_count + 1;

assign bit_count = bit_count_inc;

Wait, but we need to handle bypass_scrambling.

We can add an always block for bypass:

always_comb begin
    if (bypass_scrambling) begin
        data_out = data_in;
        valid_out = valid_in;
        bit_count = bit_count_inc;
    end else begin
        // normal operation
        data_out = ud(data_in ^ prbs);
        valid_out = valid_in;
        bit_count = bit_count + 1;
    end
end

But we need to consider the latch for data_in.

Alternatively, we can use a separate always block.

Let's try to simplify.

We need to ensure the module meets the latency requirements.

We'll need to use blocking assignments.

Let's produce a minimal code that covers the requirements.

I'll write the code:

