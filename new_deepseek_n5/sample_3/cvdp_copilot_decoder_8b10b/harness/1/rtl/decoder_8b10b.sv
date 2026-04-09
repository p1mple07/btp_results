module decoder_8b10b (
    input  logic        clk_in,       // trigger on rising edge
    input  logic        reset_in,     // reset_in, assert HI
    input  logic [9:0]  decoder_in,   // 10bit input
    output logic [7:0]  decoder_out,  // 8bit decoded output
    output logic        control_out   // control char, assert HI for control words
);

case (decoder_in)
  0011110100: decoder_out = 00011100; control_out = 1;
  1100001011: decoder_out = 00011100; control_out = 1;
  0011111001: decoder_out = 00111100; control_out = 1;
  1100000110: decoder_out = 00111100; control_out = 1;
  0011110010: decoder_out = 00111000; control_out = 1;
  1100001101: decoder_out = 00111000; control_out = 1;
  0011110110: decoder_out = 00110000; control_out = 1;
  1100001111: decoder_out = 00110000; control_out = 1;
  0011111010: decoder_out = 01111000; control_out = 1;
  1100000101: decoder_out = 01111000; control_out = 1;
  0011111101: decoder_out = 01111100; control_out = 1;
  1100001000: decoder_out = 01111100; control_out = 1;
  0011110001: decoder_out = 01110100; control_out = 1;
  1100001110: decoder_out = 01110100; control_out = 1;
  0011111000: decoder_out = 01110000; control_out = 1;
  1100000111: decoder_out = 01110000; control_out = 1;
  default: decoder_out = 00000000; control_out = 0;
endcase

output logic [7:0] decoder_out;
output logic control_out;

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
        decoder_out <= 00000000;
        control_out <= 0;
    end else begin
        decoder_out <= 00000000;
        control_out <= 0;
    end
endmodule