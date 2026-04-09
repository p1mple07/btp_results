module String_to_ASCII_Converter (
    input wire clk,                       // Clock signal
    input wire reset,                     // Reset signal
    input wire start,                     // Start conversion
    input wire [7:0] char_in [7:0],       // 8-character input string (7 bits per character: 0-95)
    output reg [7:0] ascii_out,           // Final latched ASCII output
    output reg valid,                     // Indicates valid output
    output reg ready                      // Indicates module ready to accept input
);
    // Custom encoding mappings
    localparam DIGIT   = 2'd0;
    localparam UPPER   = 2'd1;
    localparam LOWER   = 2'd2;
    localparam SPECIAL = 2'd3;
    // ASCII Offsets
    localparam DIGIT_OFFSET   = 8'd48;    // '0' = 48
    localparam UPPER_OFFSET   = 8'd65;    // 'A' = 65
    localparam LOWER_OFFSET   = 8'd97;    // 'a' = 97
    localparam SPECIAL_OFFSET = 8'd33;   // First special character '!' = 33
    // Initialize buffer to hold 8 ASCII values
    reg [7:0] buffer [7:0];
    // Process input string
    always @(*) begin
        if (start) begin
            // Calculate ASCII values for all characters
            buffer[0] = char_in[0] + (char_in[0] < 8'd10 ? DIGIT_OFFSET : 
                                      char_in[0] < 8'd36 ? UPPER_OFFSET : 
                                      char_in[0] < 8'd62 ? LOWER_OFFSET : 
                                      SPECIAL_OFFSET);
            buffer[1] = char_in[1] + (char_in[1] < 8'd10 ? DIGIT_OFFSET : 
                                      char_in[1] < 8'd36 ? UPPER_OFFSET : 
                                      char_in[1] < 8'd62 ? LOWER_OFFSET : 
                                      SPECIAL_OFFSET);
            buffer[2] = char_in[2] + (char_in[2] < 8'd10 ? DIGIT_OFFSET : 
                                      char_in[2] < 8'd36 ? UPPER_OFFSET : 
                                      char_in[2] < 8'd62 ? LOWER_OFFSET : 
                                      SPECIAL_OFFSET);
            buffer[3] = char_in[3] + (char_in[3] < 8'd10 ? DIGIT_OFFSET : 
                                      char_in[3] < 8'd36 ? UPPER_OFFSET : 
                                      char_in[3] < 8'd62 ? LOWER_OFFSET : 
                                      SPECIAL_OFFSET);
            buffer[4] = char_in[4] + (char_in[4] < 8'd10 ? DIGIT_OFFSET : 
                                      char_in[4] < 8'd36 ? UPPER_OFFSET : 
                                      char_in[4] < 8'd62 ? LOWER_OFFSET : 
                                      SPECIAL_OFFSET);
            buffer[5] = char_in[5] + (char_in[5] < 8'd10 ? DIGIT_OFFSET : 
                                      char_in[5] < 8'd36 ? UPPER_OFFSET : 
                                      char_in[5] < 8'd62 ? LOWER_OFFSET : 
                                      SPECIAL_OFFSET);
            buffer[6] = char_in[6] + (char_in[6] < 8'd10 ? DIGIT_OFFSET : 
                                      char_in[6] < 8'd36 ? UPPER_OFFSET : 
                                      char_in[6] < 8'd62 ? LOWER_OFFSET : 
                                      SPECIAL_OFFSET);
            buffer[7] = char_in[7] + (char_in[7] < 8'd10 ? DIGIT_OFFSET : 
                                      char_in[7] < 8'd36 ? UPPER_OFFSET : 
                                      char_in[7] < 8'd62 ? LOWER_OFFSET : 
                                      SPECIAL_OFFSET);
            
            // Set final output and signals
            ascii_out = buffer[7];
            valid = 1;
            ready = 1;
        end
    end
endmodule