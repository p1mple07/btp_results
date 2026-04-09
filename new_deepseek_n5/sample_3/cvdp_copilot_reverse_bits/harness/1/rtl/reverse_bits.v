module reverse_bits(
    input [31:0] num_in,
    output [31:0] num_out
);

    reg [31:0] num_out;

    generate
        for (i = 0; i < 32; i = i + 1) begin
            num_out[31 - i] = num_in[i];
        end
    endgenerate

endmodule