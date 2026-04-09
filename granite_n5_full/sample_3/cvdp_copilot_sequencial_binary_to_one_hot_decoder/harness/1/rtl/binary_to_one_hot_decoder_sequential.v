module binary_to_one_hot_decoder_sequencial #(
  parameter int BINARY_WIDTH = 5,
  parameter int OUTPUT_WIDTH = 32
)(
  input wire [BINARY_WIDTH-1:0] i_binary_in,
  input wire                        i_clk,
  input wire                        i_rstb,
  output wire [OUTPUT_WIDTH-1:0] o_one_hot_out
);

// Verify that BINARY_WIDTH is greater than or equal to 1.
generate
  if(BINARY_WIDTH < 1) begin
    $error("Invalid BINARY_WIDTH parameter: %d", BINARY_WIDTH);
  end
endgenerate

// Initialize the output with zeros.
always_ff @(posedge i_clk or posedge i_rstb) begin
  if(i_rstb == 1'b0) begin
    o_one_hot_out <= '0;
  end else begin
    // Perform the conversion based on the binary input.
    o_one_hot_out <= {{(OUTPUT_WIDTH - BINARY_WIDTH){1'b0}}, i_binary_in};
  end
end

endmodule