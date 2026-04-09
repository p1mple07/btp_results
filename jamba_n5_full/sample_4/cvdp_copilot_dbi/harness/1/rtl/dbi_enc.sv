module dbi_enc (
    input        clk,
    input        rst_n,
    input        [39:0] data_in,
    output reg   [39:0] data_out,
    output       dbi_cntrl[1:0]
);
