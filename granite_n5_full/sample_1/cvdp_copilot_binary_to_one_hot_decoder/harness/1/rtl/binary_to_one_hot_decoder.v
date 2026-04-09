module binary_to_one_hot_decoder #(
  parameter BINARY_WIDTH = 5,
  parameter OUTPUT_WIDTH = 32
) (
  input [BINARY_WIDTH-1:0] binary_in,
  output reg [OUTPUT_WIDTH-1:0] one_hot_out
);

  always @(*) begin
    case (binary_in)
      // Define cases based on the binary input range
      5'd0: one_hot_out = OUTPUT_WIDTH'(1 << 0);
      5'd1: one_hot_out = OUTPUT_WIDTH'(1 << 1);
      5'd2: one_hot_out = OUTPUT_WIDTH'(1 << 2);
      5'd3: one_hot_out = OUTPUT_WIDTH'(1 << 3);
      5'd4: one_hot_out = OUTPUT_WIDTH'(1 << 4);
      default: one_hot_out = '0;
    endcase
  end

endmodule