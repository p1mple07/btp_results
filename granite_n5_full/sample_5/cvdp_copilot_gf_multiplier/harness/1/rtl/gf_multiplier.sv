module gf_multiplier(
  input [3:0] A, // Input multiplicand
  input [3:0] B, // Input multiplier
  output reg [3:0] result // Output product
);

  parameter IRREDUCIBLE_POLY = 5'b10011; // Irreducible polynomial

  always @(*) begin
    result = 0;
    for (int i = 0; i < 4; i++) begin
      if (B[i] == 1) begin
        result = result ^ A;
        if (A[3] == 1) begin
          A = A ^ IRREDUCIBLE_POLY;
        end
      end else begin
        if (A[3] == 1) begin
          A = A ^ IRREDUCIBLE_POLY;
        end
      end
      A = A >> 1;
    end
  end

endmodule