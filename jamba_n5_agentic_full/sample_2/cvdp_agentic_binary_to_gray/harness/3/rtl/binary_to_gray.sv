module binary_to_gray #(
    int WIDTH = 6
) (
    input  [WIDTH-1:0] binary_in,
    output [WIDTH-1:0] gray_out
);

    assign gray_out = {binary_in[WIDTH-1]};
    generate
        for (integer i = 0; i < WIDTH-1; i=i+1) begin
            gray_out[i] = binary_in[i] ^ binary_in[i+1];
        end
    endgenerate

endmodule
