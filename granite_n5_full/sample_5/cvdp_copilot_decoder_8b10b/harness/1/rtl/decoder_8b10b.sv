module decoder_8b10b (
    input  logic        clk_in,       // trigger on rising edge
    input  logic        reset_in,     // reset_in, assert HI
    input  logic [9:0]  decoder_in,   // 10bit input
    output logic [7:0]  decoder_out,  // 8bit decoded output
    output logic        control_out   // control char, assert HI for control words
);

// Define the valid control symbols
logic [9:0] const_valid_ctrl_symbols = 10'b0011110100;

// Create a local variable to hold the input data
logic [9:0] s_in_10b_reg;  

// Define the internal signals
logic [7:0] s_decoder_out; 
logic         s_control_out;    

// Instantiate the decoder logic
decoder dut_1 (
   .clk_in(clk_in),
   .reset_in(reset_in),
   .decoder_in(s_in_10b_reg),
   .decoder_out(s_decoder_out),
   .control_out(s_control_out)
);

// Decode the input using the valid control symbols
assign s_control_out = (s_in_10b_reg == const_valid_ctrl_symbols);
assign s_decoder_out = (s_in_10b_reg == const_valid_ctrl_symbols)? s_in_10b_reg[9:2] : (s_in_10b_reg & 0x01);

endmodule