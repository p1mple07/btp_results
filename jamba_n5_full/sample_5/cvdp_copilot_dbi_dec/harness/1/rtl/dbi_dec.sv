module dbi_dec (
    input  wire        rst_n,
    input  wire        clk,
    input  wire [39:0] data_in,
    input  wire [1:0] dbi_cntrl,
    output wire [39:0] data_out
);

    wire [19:0] inv_group0;
    wire [19:0] inv_group1;

    assign inv_group0 = data_in[39:20] ^ (dbi_cntrl[0] == 1);
    assign inv_group1 = data_in[19:0] ^ (dbi_cntrl[1] == 1);

    assign data_out = inv_group0 xor inv_group1;

endmodule
