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
  
// Define valid 10b codes and their 8b outputs
rom logic [7:0] valid_codes[16] = 
    10b0011110100 # 8'h1C,
    10b1100001011 # 8'h1C,
    10b0011111001 # 8'h1C,
    10b1100000110 # 8'h1C,
    10b0011110101 # 8'h1C,
    10b1100001010 # 8'h1C,
    10b0011111000 # 8'h1C,
    10b1100000111 # 8'h1C,
    10b1110101000 # 8'h1C,
    10b0001010111 # 8'h1C,
    10b1101101000 # 8'h1C,
    10b0010010111 # 8'h1C,
    10b1011101000 # 8'h1C,
    10b0100010111 # 8'h1C,
    10b1011100001 # 8'h1C,
    10b0100011001 # 8'h1C
  ;

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
        s_in_10b_reg <= 10'b0000000000;
        s_decoder_out <= 8'b00000000;
        s_control_out <= 1'b0;
    else begin
        s_in_10b_reg <= decoder_in;
        s_decoder_out <= 8'b00000000;
        s_control_out <= 1'b0;

        // Match valid codes
        case (s_in_10b_reg)
        // ... (all valid 10b codes) ...
        default:
            decoder_out <= 8'b00000000;
            control_out <= 1'b0;
        endcase
    end
endmodule