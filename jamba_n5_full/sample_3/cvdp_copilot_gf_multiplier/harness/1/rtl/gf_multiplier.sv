module gf_multiplier(
    input [3:0] A,
    input [3:0] B,
    output reg [3:0] result
);

  reg [3:0] irreducible_poly = 5'b10011;

  always @(*) begin
    reg temp;
    for (int i = 0; i < 4; i++) begin
      if (B[i]) begin
        result = result ^ A;
        A = A << 1;
        if (A[3]) begin
          A = A ^ irreducible_poly;
        end
      end else begin
        A = A << 1;
        if (A[3]) begin
          A = A ^ irreducible_poly;
        end
      end
    end
  end

  assign result = result;

endmodule
