module reverse_bits(
    input [31:0] num_in,
    output reg [31:0] num_out
);

    // Initialize output to all zeros
    always @* begin
        num_out = 32'b0;
    end

    // Iterate through each bit of the input
    for (integer i = 0; i < 32; i = i + 1) begin
        // Set the bit in the output to the bit in the input at the mirrored position
        num_out[31 - i] = num_in[i];
    end

endmodule
