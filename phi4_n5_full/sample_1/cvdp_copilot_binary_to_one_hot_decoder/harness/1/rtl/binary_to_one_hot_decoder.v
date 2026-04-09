module binary_to_one_hot_decoder #(
  parameter BINARY_WIDTH = 5,
  parameter OUTPUT_WIDTH = 32
)(
  input  wire [BINARY_WIDTH-1:0] binary_in,
  output wire [OUTPUT_WIDTH-1:0] one_hot_out
);

  genvar i;
  generate
    for(i = 0; i < OUTPUT_WIDTH; i = i + 1) begin : decoder_loop
      assign one_hot_out[i] = (binary_in == i);
    end
  endgenerate

endmodule