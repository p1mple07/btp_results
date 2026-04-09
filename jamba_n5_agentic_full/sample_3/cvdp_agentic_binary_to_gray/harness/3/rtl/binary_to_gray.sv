module binary_to_gray #(
    parameter WIDTH = 6
) (
    input  logic [WIDTH-1:0] binary_in,
    output logic [WIDTH-1:0] gray_out
);

    assign gray_out = binary_in[WIDTH-1];
    for (int i = 0; i < WIDTH-2; i=i+1) begin
        gray_out[i] = binary_in[i] ^ binary_in[i+1];
    end

endmodule
