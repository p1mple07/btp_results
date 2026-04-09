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
            10'b0011110100: s_decoder_out <= 8'h1C; s_control_out <= 1'b1;
            10'b1100001011: s_decoder_out <= 8'h1C; s_control_out <= 1'b1;
            10'b0011110101: s_decoder_out <= 8'h92; s_control_out <= 1'b1;
            10'b1100001010: s_decoder_out <= 8'h92; s_control_out <= 1'b1;
            10'b0011110100: s_decoder_out <= 8'h124; s_control_out <= 1'b1;
            10'b1100001100: s_decoder_out <= 8'h124; s_control_out <= 1'b1;
            10'b0011110011: s_decoder_out <= 8'h156; s_control_out <= 1'b1;
            10'b1100001101: s_decoder_out <= 8'h156; s_control_out <= 1'b1;
            10'b0011110010: s_decoder_out <= 8'h188; s_control_out <= 1'b1;
            10'b1100001001: s_decoder_out <= 8'h188; s_control_out <= 1'b1;
            10'b0011110110: s_decoder_out <= 8'h220; s_control_out <= 1'b1;
            10'b1100001011: s_decoder_out <= 8'h220; s_control_out <= 1'b1;
            10'b0011110000: s_decoder_out <= 8'h252; s_control_out <= 1'b1;
            10'b1100001001: s_decoder_out <= 8'h252; s_control_out <= 1'b1;
            10'b0001010111: s_decoder_out <= 8'h247; s_control_out <= 1'b1;
            10'b0010010111: s_decoder_out <= 8'h247; s_control_out <= 1'b1;
            10'b1011101000: s_decoder_out <= 8'h251; s_control_out <= 1'b1;
            10'b0100010111: s_decoder_out <= 8'h251; s_control_out <= 1'b1;
            10'b1011101000: s_decoder_out <= 8'h253; s_control_out <= 1'b1;
            10'b0100010111: s_decoder_out <= 8'h253; s_control_out <= 1'b1;
            10'b1011101000: s_decoder_out <= 8'h254; s_control_out <= 1'b1;
            10'b0100010111: s_decoder_out <= 8'h254; s_control_out <= 1'b1;
            10'b1110101000: s_decoder_out <= 8'h247; s_control_out <= 1'b1;
            10'b0001011000: s_decoder_out <= 8'h247; s_control_out <= 1'b1;
            10'b1011101000: s_decoder_out <= 8'h251; s_control_out <= 1'b1;
            10'b0100010100: s_decoder_out <= 8'h251; s_control_out <= 1'b1;
            10'b1110101000: s_decoder_out <= 8'h253; s_control_out <= 1'b1;
            10'b0100010100: s_decoder_out <= 8'h253; s_control_out <= 1'b1;
            10'b1110101000: s_decoder_out <= 8'h254; s_control_out <= 1'b1;
            10'b0100010100: s_decoder_out <= 8'h254; s_control_out <= 1'b1;
            default: s_decoder_out <= 8'b00000000; s_control_out <= 1'b0;
        endcase
    end
endmodule
