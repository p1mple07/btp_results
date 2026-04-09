module dbi_dec (
    input  wire        rst_n,
    input  wire        clk,
    input  wire [39:0] data_in,
    input  wire [1:0]  dbi_cntrl,
    output wire [39:0] data_out
);

    wire [39:0] group0_inv;
    wire [39:0] group1_inv;

    assign group0_inv = (dbi_cntrl[0] == 1) ? ~data_in[19:0] : data_in[19:0];
    assign group1_inv = (dbi_cntrl[1] == 1) ? ~data_in[39:20] : data_in[39:20];

    assign data_out = group1_inv[39:21] | group0_inv[19:0];

endmodule
