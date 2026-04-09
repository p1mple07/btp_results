module binary_to_gray (
    parameter WIDTH = 6  // Define the bit width of the input
) (
    input  wire [WIDTH-1:0] binary_in,  // Binary input
    output wire [WIDTH-1:0] gray_out    // Gray code output
);

// Calculate the Gray code using XOR operations
for (genvar i=WIDTH-2; i>=0; i--) begin : gen_gray_code
    assign gray_out[i] = binary_in[i+1] ^ binary_in[i];  // XOR operation
end

endmodule