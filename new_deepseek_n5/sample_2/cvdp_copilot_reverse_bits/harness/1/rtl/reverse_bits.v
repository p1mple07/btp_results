module reverse_bits(
    input [31:0] num_in,
    output [31:0] num_out
);

    generate
        for (int i = 0; i < 32; i = i + 1)
            num_out[31 - i] = num_in[i];
    endgenerate

endmodule