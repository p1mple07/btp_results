module binary_to_gray (
    parameter WIDTH = 6  // Define the bit width of the input
) (
    input  wire [WIDTH-1:0] binary_in,  // Binary input
    output wire [WIDTH-1:0] gray_out    // Gray code output
);

assign  gray_out[WIDTH-1] = binary_in[WIDTH-1];  // MSB is the same

generate
    for (int i = WIDTH - 2; i >= 0; i--) begin
        gray_out[i] = binary_in[i+1] ^ binary_in[i];
    end
endgenerate

endmodule
