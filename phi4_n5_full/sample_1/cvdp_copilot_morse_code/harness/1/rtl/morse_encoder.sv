// File: rtl/morse_encoder.sv

module morse_encoder (
  input  logic [7:0] ascii_in,
  output logic [9:0] morse_out,
  output logic [3:0] morse_length
);

  // Combinational logic: map the 8‐bit ASCII input to its Morse code
  // The Morse code is represented as a right‐aligned binary pattern in a 10‐bit field.
  // For each valid character, the pattern is shifted left by (10 - valid_length)
  // so that the valid bits occupy the least‐significant positions.
  always_comb begin
    case (ascii_in)
      8'h41: begin
        // A (.-) -> pattern "01" (2 bits), valid length = 2
        morse_out = (2'b01) << (10 - 2);
        morse_length = 4'd2;
      end
      8'h42: begin
        // B (-...) -> pattern "1000" (4 bits), valid length = 4
        morse_out = (4'b1000) << (10 - 4);
        morse_length = 4'd4;
      end
      8'h43: begin
        // C (-.-.) -> pattern "1010" (4 bits), valid length = 4
        morse_out = (4'b1010) << (10 - 4);
        morse_length = 4'd4;
      end
      8'h44: begin
        // D (-..) -> pattern "100" (3 bits), valid length = 3
        morse_out = (3'b100) << (10 - 3);
        morse_length = 4'd3;
      end
      8'h45: begin
        // E (.) -> pattern "0" (1 bit), valid length = 1
        morse_out = (1'b0) << (10 - 1);
        morse_length = 4'd1;
      end
      8'h46: begin
        // F (..-.): pattern "0010" (4 bits), valid length = 4
        morse_out = (4'b0010) << (10 - 4);
        morse_length = 4'd4;
      end
      8'h47: begin
        // G (--.): pattern "110" (3 bits), valid length = 3
        morse_out = (3'b110) << (10 - 3);
        morse_length = 4'd3;
      end
      8'h48: begin
        // H (....): pattern "0000" (4 bits), valid length = 4
        morse_out = (4'b0000) << (10 - 4);
        morse_length = 4'd4;
      end
      8'h49: begin
        // I (..): pattern "00" (2 bits), valid length = 2
        morse_out = (2'b00) << (10 - 2);
        morse_length = 4'd2;
      end
      8'h4A: begin
        // J (.---): pattern "0111" (4 bits), valid length = 4
        morse_out = (4'b0111) << (10 - 4);
        morse_length = 4'd4;
      end
      8'h4B: begin
        // K (-.-): pattern "101" (3 bits), valid length = 3
        morse_out = (3'b101) << (10 - 3);
        morse_length = 4