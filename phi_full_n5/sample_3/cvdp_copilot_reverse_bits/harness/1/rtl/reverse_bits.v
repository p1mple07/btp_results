module reverse_bits(
    input [31:0] num_in,
    output reg [31:0] num_out
);

    // Initialize the output with all zeros
    assign num_out = 32'b0;

    // Iterate through each bit of the input and assign it to the corresponding bit in the output
    integer i;
    always @(num_in) begin
        for (i = 0; i < 32; i = i + 1) begin
            num_out[i] = num_in[31 - i];
        end
    end

endmodule
