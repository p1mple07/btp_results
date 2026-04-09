module binary_to_one_hot_decoder_sequencial #(
    parameter BINARY_WIDTH = 5,
    parameter OUTPUT_WIDTH = 32
)(
    input  wire                      i_clk,
    input  wire                      i_rstb,
    input  wire [BINARY_WIDTH-1:0]   i_binary_in,
    output reg  [OUTPUT_WIDTH-1:0]   o_one_hot_out
);

  // Parameter check: Ensure OUTPUT_WIDTH is large enough to represent all values up to 2^BINARY_WIDTH - 1.
  generate
    if (OUTPUT_WIDTH < (1 << BINARY_WIDTH)) begin : param_check
      $error("Parameter ERROR: OUTPUT_WIDTH (%0d) must be >= 2^(BINARY_WIDTH) (%0d) for BINARY_WIDTH=%0d.",
             OUTPUT_WIDTH, (1 << BINARY_WIDTH), BINARY_WIDTH);
    end
  endgenerate

  // Sequential process: Sample the binary input on the rising edge of the clock and update the one-hot output.
  always @(posedge i_clk or negedge i_rstb) begin : one_hot_proc
    integer j;
    reg [OUTPUT_WIDTH-1:0] one_hot;

    if (!i_rstb) begin
      o_one_hot_out <= {OUTPUT_WIDTH{1'b0}};
    end else begin
      // Initialize the one-hot temporary register to all zeros.
      one_hot = {OUTPUT_WIDTH{1'b0}};
      // Loop through all bits of the output vector.
      for (j = 0; j < OUTPUT_WIDTH; j = j + 1) begin
         // Set the bit corresponding to the sampled binary input.
         if (j == i_binary_in)
            one_hot[j] = 1'b1;
         else
            one_hot[j] = 1'b0;
      end
      o_one_hot_out <= one_hot;
    end
  end

endmodule