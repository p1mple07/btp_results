module morse_encoder (
  input  logic [7:0] ascii_in,
  output logic [9:0] morse_out,
  output logic [3:0] morse_length
);

  always_comb begin
    // Default values: no valid Morse code
    morse_out  = 10'b0;
    morse_length = 4'd0;
    
    case (ascii_in)
      8'h41: begin // A: .-   --> 10'b01, length = 2
        morse_out  = 10'b01;
        morse_length = 4'd2;
      end
      8'h42: begin // B: -... --> 10'b1000, length = 4
        morse_out  = 10'b1000;
        morse_length = 4'd4;
      end
      8'h43: begin // C: -.-. --> 10'b1010, length = 4