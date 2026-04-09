module priority_encoder_8x3 (
  input wire [7:0] in,
  output logic [2:0] out
);

  always_comb begin
    casez(in)
      8'b1000000: out = 3'b111;
      8'b0100000: out = 3'b110;
      8'b0010000: out = 3'b101;
      8'b0001000: out = 3'b011;
      8'b0000100: out = 3'b110;
      8'b0000010: out = 3'b101;
      8'b0000001: out = 3'b011;
      default: out = 3'b000; // Default to 0 when no inputs are active
    endcase
  end

endmodule