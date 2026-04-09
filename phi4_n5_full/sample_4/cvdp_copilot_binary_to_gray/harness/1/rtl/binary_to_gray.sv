module binary_to_gray (
    parameter WIDTH = 6
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

assign gray_out[WIDTH-1] = binary_in[WIDTH-1];  // MSB is the same

generate
    genvar i;
    for (i = WIDTH-2; i >= 0; i = i - 1) begin : gen_gray
        assign gray_out[i] = binary_in[i+1] ^ binary_in[i];
    end
endgenerate

endmodule