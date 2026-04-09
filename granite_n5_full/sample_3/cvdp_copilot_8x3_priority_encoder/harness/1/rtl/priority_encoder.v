module priority_encoder_8x3 (
  input wire [7:0] in,
  output logic [2:0] out
);

  always_comb begin
    case (in)
      8'hFF: out = 3'b111; // Bit 7 is high, so we output 3'b111 regardless of the other bits.
      8'hFE: out = 3'b110;
      8'hFD: out = 3'b101;
      8'hFC: out = 3'b100;
      8'hFB: out = 3'b011;
      8'hFA: out = 3'b010;
      8'hF9: out = 3'b001;
      8'hF8: out = 3'b000;
      default: out = 3'b000; // Default to 3'b000 if none of the input lines are active.
    endcase
  end

endmodule