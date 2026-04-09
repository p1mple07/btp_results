module binary_to_one_hot_decoder_sequencial #(
  parameter BINARY_WIDTH = 5,
  parameter OUTPUT_WIDTH = 32
)(
  input  wire [BINARY_WIDTH-1:0] i_binary_in,
  input  wire                     i_clk,
  input  wire                     i_rstb,
  output reg  [OUTPUT_WIDTH-1:0]  o_one_hot_out
);

  // Combinational logic to generate one-hot vector.
  // Only the bit at index i_binary_in is set to 1.
  reg [OUTPUT_WIDTH-1:0] one_hot;
  always @(*) begin
    one_hot = {OUTPUT_WIDTH{1'b0}};
    // Set the bit corresponding to the binary input.
    one_hot[i_binary_in] = 1'b1;
  end

  // Sequential logic: sample input and update output on rising edge of clock.
  // Asynchronous reset: when i_rstb is low, o_one_hot_out is reset to 0.
  always @(posedge i_clk or negedge i_rstb) begin
    if (!i_rstb)
      o_one_hot_out <= {OUTPUT_WIDTH{1'b0}};
    else
      o_one_hot_out <= one_hot;
  end

endmodule