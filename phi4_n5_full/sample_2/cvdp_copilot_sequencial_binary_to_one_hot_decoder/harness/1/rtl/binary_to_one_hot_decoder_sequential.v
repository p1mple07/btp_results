module binary_to_one_hot_decoder_sequencial #(
    parameter BINARY_WIDTH = 5,
    parameter OUTPUT_WIDTH = 32
)(
    input  wire         i_clk,
    input  wire         i_rstb,
    input  wire [BINARY_WIDTH-1:0] i_binary_in,
    output reg  [OUTPUT_WIDTH-1:0] o_one_hot_out
);

  // Parameter constraint: OUTPUT_WIDTH must be at least 2^BINARY_WIDTH.
  // This check is for simulation and will generate an error if the constraint is violated.
  initial begin
      if (OUTPUT_WIDTH < (1 << BINARY_WIDTH)) begin
          $error("Parameter error: OUTPUT_WIDTH (%0d) must be at least %0d (2^BINARY_WIDTH)", OUTPUT_WIDTH, (1 << BINARY_WIDTH));
      end
  end

  always @(posedge i_clk or negedge i_rstb) begin
      if (!i_rstb) begin
          o_one_hot_out <= {OUTPUT_WIDTH{1'b0}};
      end else begin
          // Reset the output to all zeros.
          o_one_hot_out <= {OUTPUT_WIDTH{1'b0}};
          // Set only the bit corresponding to i_binary_in, if within range.
          if (i_binary_in < OUTPUT_WIDTH)
              o_one_hot_out[i_binary_in] <= 1'b1;
      end
  end

endmodule