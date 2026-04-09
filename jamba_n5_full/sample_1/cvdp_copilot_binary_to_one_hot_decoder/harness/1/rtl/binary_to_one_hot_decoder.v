module binary_to_one_hot_decoder #(
  parameter BINARY_WIDTH = 5,
  parameter OUTPUT_WIDTH = 32
) (
  input wire logic [BINARY_WIDTH-1:0] binary_in,
  output logic [OUTPUT_WIDTH-1:0] one_hot_out
);

  initial begin
    one_hot_out = {repeat(OUTPUT_WIDTH, 0)} 1;
  end

  always @(*) begin
    if (binary_in < OUTPUT_WIDTH) begin
      one_hot_out[binary_in] = 1;
    end
  end

endmodule
