module binary_to_one_hot_decoder #(
    parameter BINARY_WIDTH = 5,
    parameter OUTPUT_WIDTH = 32
) (
    input wire [BINARY_WIDTH-1:0] binary_in,
    input wire       OUTPUT_WIDTH,
    output reg [OUTPUT_WIDTH-1:0] one_hot_out
);

genvar i;
generate
    for (i = 0; i < OUTPUT_WIDTH; i++) begin
        assign one_hot_out[i] = (binary_in[i] == 1) ? 1 : 0;
    end
endgenerate

endmodule
