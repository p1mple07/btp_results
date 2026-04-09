module priority_encoder_8x3 (
  input [7:0] in, // 8-bit input vector
  output reg [2:0] out // 3-bit output vector
);
  
  always @(*) begin
    case(in)
      8'b1000000: out = 3'b111; // Highest priority input line is in[7]
      8'b0100000: out = 3'b110;
      8'b0010000: out = 3'b101;
      8'b0001000: out = 3'b100;
      8'b0000100: out = 3'b011;
      8'b0000010: out = 3'b010;
      8'b0000001: out = 3'b001;
      default: out = 3'b000; // Default to 000 when no active input line
    endcase
  end
  
endmodule

// File: rtl/priority_encoder.v
// Author: [Your Name]
// Description: Priority encoder module

module priority_encoder_8x3 (
  input [7:0] in, // 8-bit input vector
  output reg [2:0] out // 3-bit output vector
);

  always @(*) begin
    case(in)
      8'b1000000: out = 3'b111; // Highest priority input line is in[7]
      8'b0100000: out = 3'b110;
      8'b0010000: out = 3'b101;
      8'b0001000: out = 3'b100;
      8'b0000100: out = 3'b011;
      8'b0000010: out = 3'b010;
      8'b0000001: out = 3'b001;
      default: out = 3'b000; // Default to 000 when no active input line
    endcase
  end

endmodule