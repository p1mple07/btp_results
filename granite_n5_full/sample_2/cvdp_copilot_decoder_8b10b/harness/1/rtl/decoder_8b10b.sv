module decoder_8b10b (
    input  logic        clk_in,       // trigger on rising edge
    input  logic        reset_in,     // reset_in, assert HI
    input  logic [9:0]  decoder_in,   // 10bit input
    output logic [7:0]  decoder_out,  // 8bit decoded output
    output logic        control_out   // control char, assert HI for control words
);

// Define the valid control symbols
localparam logic [7:0] c_valid_symbols[8] = {
    8'h1C, // K.28.0
    8'h3C, // K.28.1
    8'h5C, // K.28.2
    8'h7C, // K.28.3
    8'h9C, // K.28.4
    8'hBC, // K.28.5
    8'hDC, // K.28.6
    8'hFC  // K.28.7
};

logic [7:0] s_in_10b_reg;  
logic [7:0] s_decoder_out; 
logic s_control_out;     

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
        s_in_10b_reg <= 10'b000000000;
        s_decoder_out <= 8'b0000000;
        s_control_out <= 1'b0;
    end else begin
        s_in_10b_reg <= decoder_in;
        s_decoder_out <= 8'b0000000;
        s_control_out <= 1'b0;

        // Insert code here to decode the incoming 10-bit code with the valid control symbols
        
        // Replace the comments "INSERT CODE HERE" with your code to decode the incoming 10-bit code with the valid control symbols.
        
    }
endmodule