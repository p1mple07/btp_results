module decoder_8b10b (
    input  logic        clk_in,       // trigger on rising edge
    input  logic        reset_in,     // reset_in, assert HI
    input  logic [9:0]  decoder_in,   // 10-bit input
    output logic [7:0]  decoder_out,  // 8-bit decoded output
    output logic        control_out   // control char, assert HI for control words
);

logic [9:0] s_in_10b_reg;  
logic [7:0] s_decoder_out; 
logic s_control_out;     

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
        s_in_10b_reg   <= 10'b0000000000;
        s_decoder_out  <= 8'b00000000;
        s_control_out  <= 1'b0;
    end else begin
        s_in_10b_reg   <= decoder_in;
        s_decoder_out  <= 8'b00000000;
        s_control_out  <= 1'b0;

        // Decode the incoming 10-bit code with valid control symbols
        case (s_in_10b_reg)
            10'b0011110100: begin s_decoder_out = 8'h1C; s_control_out = 1'b1; end
            10'b1100001011: begin s_decoder_out = 8'h1C; s_control_out = 1'b1; end
            10'b0011111001: begin s_decoder_out = 8'h3C; s_control_out = 1'b1; end
            10'b1100000110: begin s_decoder_out = 8'h3C; s_control_out = 1'b1; end
            10'b0011110101: begin s_decoder_out = 8'h5C; s_control_out = 1'b1; end
            10'b1100001010: begin s_decoder_out = 8'h5C; s_control_out = 1'b1; end
            10'b0011110011: begin s_decoder_out = 8'h7C; s_control_out = 1'b1; end
            10'b1100001100: begin s_decoder_out = 8'h7C; s_control_out = 1'b1; end
            10'b0011110010: begin s_decoder_out = 8'h9C; s_control_out = 1'b1; end
            10'b1100001101: begin s_decoder_out = 8'h9C; s_control_out = 1'b1; end
            10'b0011111010: begin s_decoder_out = 8'hBC; s_control_out = 1'b1; end
            10'b1100000101: begin s_decoder_out = 8'hBC; s_control_out = 1'b1; end
            10'b0011110110: begin s_decoder_out = 8'hDC; s_control_out = 1'b1; end
            10'b1100001001: begin s_decoder_out = 8'hDC; s_control_out = 1'b1; end
            10'b0011111000: begin s_decoder_out = 8'hFC; s_control_out = 1'b1; end
            10'b1100000111: begin s_decoder_out = 8'hFC; s_control_out = 1'b1; end
            10'b1110101000: begin s_decoder_out = 8'hF7; s_control_out = 1'b1; end
            10'b0001010111: begin s_decoder_out = 8'hF7; s_control_out = 1'b1; end
            10'b1101101000: begin s_decoder_out = 8'hFB; s_control_out = 1'b1; end
            10'b0010010111: begin s_decoder_out = 8'hFB; s_control_out = 1'b1; end
            10'b1011101000: begin s_decoder_out = 8'hFD; s_control_out = 1'b1; end
            10'b0100010111: begin s_decoder_out = 8'hFD; s_control_out = 1'b1; end
            10'b0111101000: begin s_decoder_out = 8'hFE; s_control_out = 1'b1; end
            10'b1000010111: begin s_decoder_out = 8'hFE; s_control_out = 1'b1; end
            default: begin s_decoder_out = 8'b00000000; s_control_out = 1'b0; end
        endcase
    end
end

assign decoder_out = s_decoder_out;
assign control_out = s_control_out;

endmodule