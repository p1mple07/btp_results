module gf_multiplier (
  input [3:0] A,
  input [3:0] B,
  output [3:0] result
);

  localparam irreducible_poly = 5'b10011;

  always @(*) begin

    wire [3:0] temp_A;

    temp_A = A;

    for (int i = 0; i < 4; i++) begin
      if (B[i] == 1) begin
        result = result ^ A;
        A = A << 1;
        if (A[3] == 1) begin
          A = A ^ irreducible_poly;
        end
      end else begin
        A = A << 1;
      end
    end

  end

  assign result = temp_A;

endmodule
