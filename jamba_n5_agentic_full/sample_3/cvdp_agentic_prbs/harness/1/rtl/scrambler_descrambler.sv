module scrambler_descrambler #(
    parameter CHECK_MODE = 0,
    parameter POLY_LENGTH = 31,
    parameter POLY_TAP = 3,
    parameter WIDTH = 16
)(
    input clk,
    input rst,
    input bypass_scrambling,
    input [WIDTH-1:0] data_in,
    input valid_in,
    output reg [WIDTH-1:0] data_out,
    output reg valid_out,
    output bit_count
);

// Instantiate the PRBS generator/checker module
prbs_gen_check uut(
    .clk(clk),
    .rst(rst),
    .bypass_scrambling(bypass_scrambling),
    .data_in(data_in),
    .data_out(data_out),
    .valid_out(valid_out),
    .bit_count(bit_count)
);

// Generate bit_count: increments on every valid_in=1.
always_comb begin
    bit_count = (valid_in && !rst) ? 0 : bit_count + 1;
end

// Validity: valid_out is true when valid_in is 1 and rst is low, etc.
assign valid_out = valid_in & !rst;

// Provide the outputs as per the interface.

endmodule
