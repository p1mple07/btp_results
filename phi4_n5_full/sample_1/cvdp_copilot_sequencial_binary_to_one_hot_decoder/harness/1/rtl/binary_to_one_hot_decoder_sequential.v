module binary_to_one_hot_decoder_sequencial #(
  parameter BINARY_WIDTH = 5,
  parameter OUTPUT_WIDTH = 32
)(
  input  wire                     i_clk,
  input  wire                     i_rstb,
  input  wire [BINARY_WIDTH-1:0]  i_binary_in,
  output reg  [OUTPUT_WIDTH-1:0]  o_one_hot_out
);

  // Ensure that OUTPUT_WIDTH is large enough to represent all values up to 2^BINARY_WIDTH - 1
  localparam integer MIN_OUTPUT_WIDTH = (1 << BINARY_WIDTH);

  initial begin
    if (OUTPUT_WIDTH < MIN_OUTPUT_WIDTH)
      $error("OUTPUT_WIDTH must be at least 2^BINARY_WIDTH");
  end

  integer j;
  reg [OUTPUT_WIDTH-1:0] one_hot;

  always @(posedge i_clk or negedge i_rstb) begin
    if (!i_rstb)
      o_one_hot_out <= 0;
    else begin
      one_hot = 0;
      for (j = 0; j < OUTPUT_WIDTH; j = j + 1) begin
        if (j == i_binary_in)
          one_hot[j] = 1;
        else
          one_hot[j] = 0;
      end
      o_one_hot_out <= one_hot;
    end
  end

endmodule