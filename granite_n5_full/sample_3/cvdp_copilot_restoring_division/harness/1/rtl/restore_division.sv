module restore_division #(parameter WIDTH=6) (
  input wire clk, rst, start, [WIDTH-1:0] dividend, [WIDTH-1:0] divisor,
  output logic [WIDTH-1:0] quotient, [WIDTH-1:0] remainder, output logic valid
);

  localparam N = $clog2(WIDTH); // Number of bits needed to store a number less than WIDTH
  logic signed [N-1:0] remainder_s, dividend_s; // Signed versions of remainder and dividend
  logic signed [WIDTH-1:0] quotient_s; // Signed version of the quotient

  always @(posedge clk) begin
    if (!rst) begin
      remainder <= '0;
      dividend <= '0;
      valid <= 0;
      quotient <= '0;
    end else begin
      if (start && valid) begin
        // Shift remainder left by one bit
        remainder_s <= {remainder[WIDTH-2:0], 1'b0};
        // Append MSB of dividend
        remainder_s <= remainder_s + dividend_s[WIDTH-1];

        // Subtract divisor from remainder
        quotient_s <= remainder_s / dividend_s;
        remainder_s <= remainder_s % dividend_s;

        // Check if the most significant bit (MSB) of the subtraction result is 0
        valid <= $signed(remainder_s) >= 0;
        // If MSB is 0, set the quotient bit for this step to 1 and keep the result of the subtraction
        if (~remainder_s[WIDTH-1]) begin
          quotient <= {quotient[WIDTH-2:0], 1'b0} | $unsigned({1'b0, quotient_s});
        // If MSB is 1, restore the remainder by discarding the quotient bit
        end else begin
          remainder <= remainder_s[WIDTH-2:0];
        end
      end
    end
  end

endmodule