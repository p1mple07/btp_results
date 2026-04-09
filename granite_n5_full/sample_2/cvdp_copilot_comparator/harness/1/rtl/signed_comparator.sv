module signed_unsigned_comparator #(
  parameter WIDTH = 5
)(
  input wire [WIDTH-1:0] i_A,
  input wire [WIDTH-1:0] i_B,
  input wire              i_enable,
  input wire              i_mode,
  output wire             o_greater,
  output wire             o_less,
  output wire             o_equal
);

  // Behavioral Model
  always_comb begin
    if (!i_enable) begin
      o_greater <= 1'b0;
      o_less    <= 1'b0;
      o_equal   <= 1'b0;
    end else begin
      int A_int = $signed(i_A);
      int B_int = $signed(i_B);

      if (i_mode === 1'b1) begin
        if (A_int > B_int) begin
          o_greater <= 1'b1;
          o_less    <= 1'b0;
          o_equal   <= 1'b0;
        end else if (A_int < B_int) begin
          o_greater <= 1'b0;
          o_less    <= 1'b1;
          o_equal   <= 1'b0;
        end else begin
          o_greater <= 1'b0;
          o_less    <= 1'b0;
          o_equal   <= 1'b1;
        end
      } else begin
        if (A_int > B_int) begin
          o_greater <= 1'b1;
          o_less    <= 1'b0;
          o_equal   <= 1'b0;
        end else if (A_int < B_int) begin
          o_greater <= 1'b0;
          o_less    <= 1'b1;
          o_equal   <= 1'b0;
        end else begin
          o_greater <= 1'b0;
          o_less    <= 1'b0;
          o_equal   <= 1'b1;
        end
      end
    end
  end

endmodule