module morse_encoder (
  input logic [7:0] ascii_in, // 8-bit ASCII character to encode
  output logic [9:0] morse_out, // Output Morse code as a right-aligned binary sequence
  output logic [3:0] morse_length // Indicates the number of valid bits in morse_out
);

  always_comb begin
    case(ascii_in)
      8'h41: morse_out = 10'b01; //.-
      8'h42: morse_out = 10'b1000; // -...
      8'h43: morse_out = 10'b1010; // -.-.
      8'h44: morse_out = 10'b100; // -..
      8'h45: morse_out = 10'b0; //.
      8'h46: morse_out = 10'b0010; //..-.
      8'h47: morse_out = 10'b110; // --.
      8'h48: morse_out = 10'b0000; //....
      8'h49: morse_out = 10'b00; //..
      8'h4A: morse_out = 10'b0111; //.---
      8'h4B: morse_out = 10'b101; // -.--
      8'h4C: morse_out = 10'b1000; // -.-.
      8'h4D: morse_out = 10'b1001; // -..
      8'h4E: morse_out = 10'b110; // ---
      8'h4F: morse_out = 10'b111; //.--.
      8'h50: morse_out = 10'b0110; // --..
      8'h51: morse_out = 10'b1101; // -.--.
      8'h52: morse_out = 10'b010; //.-.
      8'h53: morse_out = 10'b000; //...
      8'h54: morse_out = 10'b0; // -
      8'h55: morse_out = 10'b1; // 1
      8'h56: morse_out = 10'b001; //.-.
      8'h57: morse_out = 10'b011; //.--.
      8'h58: morse_out = 10'b111; // ---
      8'h59: morse_out = 10'b1011; //.--.
      8'h5A: morse_out = 10'b1100; // --..
      default: morse_out = 10'b0000000; // 000
    endcase

    // Count the number of valid bits in the morse_out sequence
    integer count;
    assign count = $countones($bits(morse_out));

    // Create a binary representation of the Morse code sequence
    assign morse_binary = {morse_out};
endmodule