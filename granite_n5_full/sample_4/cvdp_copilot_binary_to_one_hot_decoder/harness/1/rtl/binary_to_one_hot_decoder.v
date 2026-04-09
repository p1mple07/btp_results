module binary_to_one_hot_decoder #(
  parameter int BINARY_WIDTH = 5,
  parameter int OUTPUT_WIDTH = 32
)(
  input [BINARY_WIDTH-1:0] binary_in,
  output logic [OUTPUT_WIDTH-1:0] one_hot_out
);

  generate
    if (OUTPUT_WIDTH < 2**BINARY_WIDTH) begin
      assign one_hot_out = '0;
    end else begin
      assign one_hot_out = {{(OUTPUT_WIDTH - BINARY_WIDTH){1'b0}}, binary_in};
    end
  endgenerate

endmodule