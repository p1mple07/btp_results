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

        // Mapping valid control symbols to outputs
        integer code;
        code = s_in_10b_reg;

        case (code)
            0b0011110100: 
                decoder_out <= 8'h1C;
                control_out <= 1;
            0b1100001011: 
                decoder_out <= 8'h1C;
                control_out <= 1;
            0b0011111001: 
                decoder_out <= 8'h3C;
                control_out <= 1;
            0b1100000110: 
                decoder_out <= 8'h3C;
                control_out <= 1;
            0b0011110101: 
                decoder_out <= 8'h5C;
                control_out <= 1;
            0b1100001010: 
                decoder_out <= 8'h5C;
                control_out <= 1;
            0b0011110011: 
                decoder_out <= 8'h7C;
                control_out <= 1;
            0b1100001100: 
                decoder_out <= 8'h7C;
                control_out <= 1;
            0b0011110010: 
                decoder_out <= 8'h10C;
                control_out <= 1;
            0b1100001101: 
                decoder_out <= 8'h10C;
                control_out <= 1;
            0b0011111010: 
                decoder_out <= 8'h12C;
                control_out <= 1;
            0b1100000101: 
                decoder_out <= 8'h12C;
                control_out <= 1;
            0b0011111000: 
                decoder_out <= 8'h14C;
                control_out <= 1;
            0b1100001111: 
                decoder_out <= 8'h14C;
                control_out <= 1;
            0b1110101000: 
                decoder_out <= 8'h16C;
                control_out <= 1;
            0b0001010111: 
                decoder_out <= 8'h16C;
                control_out <= 1;
            0b1101101000: 
                decoder_out <= 8'h23C;
                control_out <= 1;
            0b0010010111: 
                decoder_out <= 8'h23C;
                control_out <= 1;
            0b1011101000: 
                decoder_out <= 8'h27C;
                control_out <= 1;
            0b0100010111: 
                decoder_out <= 8'h27C;
                control_out <= 1;
            0b0111101000: 
                decoder_out <= 8'h30C;
                control_out <= 1;
            0b1000010111: 
                decoder_out <= 8'h30C;
                control_out <= 1;
            default:
                decoder_out <= 8'b00000000;
                control_out <= 0;
        endcase
    end
endmodule