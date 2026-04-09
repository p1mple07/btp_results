module scrambler_descrambler (
    input         clk,
    input         rst,
    input         bypass_scrambling,
    input         data_in,
    input         valid_in,
    input         data_out,
    input         valid_out,
    input         bit_count,
    output reg    data_out,
    output reg    valid_out,
    output bit_count
);

    localparam WIDTH = 16;
    localparam POLY_LENGTH = 31;
    localparam POLY_TAP = 3;
    localparam CHECK_MODE = 0;

    prbs_gen_check prbs_gen (.CLK(clk), .RST(rst), .DATA_IN(data_in), .DATA_OUT(data_out), .BIT_COUNT(bit_count));

    assign data_out = bypass_scrambling ? data_in : prbs_gen.data_out;
    assign bit_count = bit_count + (bypass_scrambling && valid_in ? WIDTH : 0);

    assign valid_out = valid_in;

endmodule
