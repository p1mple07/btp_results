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

        casez(s_in_10b_reg[9:0])
            10'b0011110100:
                s_decoder_out <= 8'b1C;
            // Add more cases for different inputs and their corresponding output values
            10'b1100001011:
                s_decoder_out <= 8'h1C;
            default:
                s_decoder_out <= 8'b00;
                s_control_out <= 1'b0;
        endcase

    end
endmodule