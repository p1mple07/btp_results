module gf_multiplier #(parameter POLY = 5'd10011)(
  input logic [3:0] A,
  input logic [3:0] B,
  output logic [3:0] result
);

  always_comb begin
    logic [3:0] multiplicand = A;
    result = 4'b0;
    for (int i=0; i<4; i++) begin
      if (B[i] == 1) begin
        result = result ^ multiplicand;
        if (multiplicand[3]) begin
          multiplicand = multiplicand << 1 ^ POLY;
        end else begin
          multiplicand = multiplicand << 1;
        end
      end else begin
        if (multiplicand[3]) begin
          multiplicand = multiplicand << 1 ^ POLY;
        end else begin
          multiplicand = multiplicand << 1;
        end
      end
    end
  end

endmodule