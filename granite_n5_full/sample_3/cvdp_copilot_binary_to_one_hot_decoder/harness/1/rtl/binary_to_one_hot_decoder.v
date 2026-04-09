module binary_to_one_hot_decoder #(
    parameter int BINARY_WIDTH = 5,
    parameter int OUTPUT_WIDTH = $clog2(BINARY_WIDTH+1)
) (
    input wire [BINARY_WIDTH-1:0] binary_in,
    output reg [OUTPUT_WIDTH-1:0] one_hot_out
);

always @(*) begin
    one_hot_out = 0;
    if (binary_in < OUTPUT_WIDTH) begin
        one_hot_out[binary_in] = 1;
    end else begin
        $display("Warning: Out-of-range binary_in detected");
    end
end

endmodule