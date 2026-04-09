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
    else begin
        s_in_10b_reg <= decoder_in;
        s_decoder_out <= 8'b00000000;
        s_control_out <= 1'b0;

        case (s_in_10b_reg)
        // K.28.0
        10'b0011110100: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        // K.28.1
        10'b1100001011: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        // K.28.2
        10'b0011110101: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        // K.28.3
        10'b1100001010: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        // K.28.4
        10'b0011110010: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        // K.28.5
        10'b1100001001: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        // K.28.6
        10'b0011111010: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        // K.28.7
        10'b1100000111: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        // K.23.7
        10'b1110100111: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        // K.27.7
        10'b1101100111: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        // K.29.7
        10'b1011100111: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        // K.30.7
        10'b0100010111: s_decoder_out = 8'h1C; s_control_out = 1'b1;
        default:
            s_decoder_out <= 8'b00000000;
            s_control_out <= 1'b0;
        endcase
    endmodule