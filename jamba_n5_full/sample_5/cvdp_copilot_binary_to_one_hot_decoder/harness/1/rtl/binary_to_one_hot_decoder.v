module binary_to_one_hot_decoder (
    input     binary_in,
    input      BINARY_WIDTH,
    input      OUTPUT_WIDTH,
    output    one_hot_out
);

reg [OUTPUT_WIDTH-1:0] one_hot_out;

always @(*) begin
    if (binary_in >= OUTPUT_WIDTH)
        one_hot_out = 0;
    else
        one_hot_out = {1'b0}[OUTPUT_WIDTH-1:0];
    one_hot_out[binary_in] = 1;
end

endmodule
