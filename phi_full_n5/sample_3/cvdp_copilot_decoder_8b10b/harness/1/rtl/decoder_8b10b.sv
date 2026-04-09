module decoder_8b10b (
    input  logic        clk_in,       // trigger on rising edge
    input  logic        reset_in,     // reset_in, assert HI
    input  logic [9:0]  decoder_in,   // 10bit input
    output logic [7:0]  decoder_out,  // 8bit decoded output
    output logic        control_out   // control char, assert HI for control words
);

logic [9:0] s_in_10b_reg;  
logic [7:0] s_decoder_out; 
logic s_control_out;     

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
        s_in_10b_reg <= 10'b0000000000;
        s_decoder_out <= 8'b00000000;
        s_control_out <= 1'b0;
    end else begin
        s_in_10b_reg <= decoder_in;
        s_decoder_out <= 8'b00000000;
        s_control_out <= 1'b0;

        case (s_in_10b_reg)
            10'b0011110100: s_decoder_out <= 8'b1C; s_control_out <= 1'b1; break;
            10'b1100001011: s_decoder_out <= 8'b1C; s_control_out <= 1'b1; break;
            10'b0011110101: s_decoder_out <= 8'b92; s_control_out <= 1'b9; break;
            10'b1100001010: s_decoder_out <= 8'b92; s_control_out <= 1'b9; break;
            10'b0011110100: s_decoder_out <= 8'b124; s_control_out <= 1'b6; break;
            10'b1100001010: s_decoder_out <= 8'b124; s_control_out <= 1'b6; break;
            10'b0011110011: s_decoder_out <= 8'b156; s_control_out <= 1'b3; break;
            10'b1100001000: s_decoder_out <= 8'b156; s_control_out <= 1'b3; break;
            10'b0011110010: s_decoder_out <= 8'b188; s_control_out <= 1'b4; break;
            10'b1100001001: s_decoder_out <= 8'b188; s_control_out <= 1'b4; break;
            10'b0011110100: s_decoder_out <= 8'b220; s_control_out <= 1'b2; break;
            10'b1100001000: s_decoder_out <= 8'b220; s_control_out <= 1'b2; break;
            10'b0011110000: s_decoder_out <= 8'b252; s_control_out <= 1'b1; break;
            10'b1100001000: s_decoder_out <= 8'b252; s_control_out <= 1'b1; break;
            10'b1110101000: s_decoder_out <= 8'b247; s_control_out <= 1'b2; break;
            10'b0001011100: s_decoder_out <= 8'b247; s_control_out <= 1'b2; break;
            10'b1011101000: s_decoder_out <= 8'b251; s_control_out <= 1'b3; break;
            10'b0100011100: s_decoder_out <= 8'b251; s_control_out <= 1'b3; break;
            10'b1011101000: s_decoder_out <= 8'b253; s_control_out <= 1'b4; break;
            10'b0100011100: s_decoder_out <= 8'b253; s_control_out <= 1'b4; break;
            10'b0111101000: s_decoder_out <= 8'b254; s_control_out <= 1'b5; break;
            10'b1000011100: s_decoder_out <= 8'b254; s_control_out <= 1'b5; break;
            default: s_decoder_out <= 8'b00000000; s_control_out <= 1'b0;
        endcase
    end
endmodule
