module morse_encoder (
  input wire [7:0] ascii_in,
  output reg [9:0] morse_out,
  output reg [3:0] morse_length
);

  always @(*) begin
    case(ascii_in)
      // Morse code mappings for ASCII characters
      8'h41: begin
        morse_out = 10'b01; //.-
        morse_length = 2;
      end
      8'h42: begin
        morse_out = 10'b1000; // -...
        morse_length = 4;
      end
      //... (other mappings)
      default: begin
        morse_out = 10'b0; // No valid Morse code for non-ASCII characters
        morse_length = 0;
      end
    endcase
  end

endmodule