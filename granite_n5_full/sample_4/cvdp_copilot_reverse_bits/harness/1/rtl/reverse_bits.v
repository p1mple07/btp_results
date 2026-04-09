module reverse_bits(
    input [31:0] num_in,
    output reg [31:0] num_out
);

assign num_out = num_in[7:0] | (num_in[15:8] << 8) | (num_in[23:16] << 16) | (num_in[31:24] << 24);

endmodule