module morse_encoder(input bit [7:0] ascii_in, output reg [9:0] morse_out, output reg [3:0] morse_length);

  case (ascii_in)
    8'h41: morse_out = "10";
    8'h42: morse_out = "-...";
    default: morse_out = 10'b0;
  endcase

  morse_length = (morse_out[9:0]) ? 4 : 0;

endmodule
