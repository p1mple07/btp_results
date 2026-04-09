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
        s_in_10b_reg <= 10'b0;
        s_decoder_out <= 8'b0;
        s_control_out <= 1'b0;
    end else begin
        s_in_10b_reg <= decoder_in;

        // Mapping of valid control symbols to 8‑bit outputs
        case (s_in_10b_reg) is
            28'd0011110100: s_decoder_out <= 8'b00011100;
            28'd1100001011: s_decoder_out <= 8'b00011100;
            28'd0011111001: s_decoder_out <= 8'b01111000;
            28'd1100000110: s_decoder_out <= 8'b01111000;
            28'd0011110101: s_decoder_out <= 8'b1011111000;
            28'd1100001010: s_decoder_out <= 8'b1100001010;
            28'd0011110011: s_decoder_out <= 8'b1111100000;
            28'd1100001100: s_decoder_out <= 8'b1100001100;
            28'd0011110010: s_decoder_out <= 8'b1100001100;
            28'd0011110110: s_decoder_out <= 8'b1100000101;
            default:
                s_decoder_out <= 8'b0;
                s_control_out <= 1'b0;
        endcase
    end
endprocess

s_control_out <= (s_control_out and (s_in_10b_reg /= 28'd0011110100 and s_in_10b_reg /= 28'd1100001011 and s_in_10b_reg /= 28'd0011111001 and s_in_10b_reg /= 28'd1100000110 and s_in_10b_reg /= 28'd0011110101 and s_in_10b_reg /= 28'd1100001010 and s_in_10b_reg /= 28'd0011110011 and s_in_10b_reg /= 28'd0011110010 and s_in_10b_reg /= 28'd0011110110));

endmodule
