// Binary to Gray Code Converter
module binary_to_gray #(
    parameter WIDTH = 4
) (
    input [WIDTH-1:0] binary_in,
    output [WIDTH-1:0] gray_out
);

    // Calculate Gray code bit by bit
    assign gray_out[0] = binary_in[0];
    for (int i = 1; i < WIDTH; i++) begin
        gray_out[i] = binary_in[i] ^ binary_in[i-1];
    end

endmodule
