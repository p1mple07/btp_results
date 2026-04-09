module String_to_ASCII_Converter (
    input wire clk,                       // Clock signal
    input wire reset,                     // Reset signal
    input wire start,                     // Start conversion
    input wire [7:0] char_in [7:0],       // 8-character input string (7 bits per character: 0-95)
    output reg [7:0] ascii_out,           // Final latched ASCII output
    output reg valid,                     // Indicates valid output
    output reg ready                      // Indicates module ready to accept input
);
    // Parameters for character type identification
    localparam DIGIT   = 2'd0;
    localparam UPPER   = 2'd1;
    localparam LOWER   = 2'd2;
    localparam SPECIAL = 2'd3;
    // ASCII Offsets
    localparam DIGIT_OFFSET   = 8'd48;    // '0' = 48
    localparam UPPER_OFFSET   = 8'd65;    // 'A' = 65
    localparam LOWER_OFFSET   = 8'd97;    // 'a' = 97
    localparam SPECIAL_OFFSET = 8'd33;   // First special character '!' = 33
    // Character types
    type char_type_t = (16#(0, 0, 0, 0, 0, 0, 0, 0));
    // Intermediate ASCII values
    reg [7:0] intermediate_ascii [0:7];
    // Determine character type for each input character
    function [1:0] determine_char_type;
        input [7:0] char;
        begin
            if (char < 8'd10)
                determine_char_type = DIGIT;    // '0'-'9'
            else if (char < 8'd36)
                determine_char_type = UPPER;    // 'A'-'Z'
            else if (char < 8'd62)
                determine_char_type = LOWER;    // 'a'-'z'
            else
                determine_char_type = SPECIAL;  // Special characters
        end
    endfunction
    // Combinational logic for ASCII calculation
    always begin
        // Determine character type for each input character
        char_type[0] = determine_char_type(char_in[0]);
        char_type[1] = determine_char_type(char_in[1]);
        char_type[2] = determine_char_type(char_in[2]);
        char_type[3] = determine_char_type(char_in[3]);
        char_type[4] = determine_char_type(char_in[4]);
        char_type[5] = determine_char_type(char_in[5]);
        char_type[6] = determine_char_type(char_in[6]);
        char_type[7] = determine_char_type(char_in[7]);
        
        // Calculate ASCII based on character type for each input character
        intermediate_ascii[0] = char_in[0] + DIGIT_OFFSET;          // '0'-'9'
        intermediate_ascii[1] = (char_in[1] - 8'd10) + UPPER_OFFSET; // 'A'-'Z'
        intermediate_ascii[2] = (char_in[2] - 8'd36) + LOWER_OFFSET; // 'a'-'z'
        intermediate_ascii[3] = (char_in[3] - 8'd62) + SPECIAL_OFFSET; // Special characters
        intermediate_ascii[4] = 8'd0;
        intermediate_ascii[5] = 8'd0;
        intermediate_ascii[6] = 8'd0;
        intermediate_ascii[7] = 8'd0;
    end
    // Sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ascii_out <= 8'd0;
            valid <= 1'b0;
            ready <= 1'b1;
            index <= 4'd0;
        else begin
            if (start && ready) begin
                // Start conversion
                index <= 7;
                ascii_out <= intermediate_ascii;
                valid <= 1'b1;
            end else if (index == 7) begin
                // Finish conversion
                ascii_out <= intermediate_ascii;
                valid <= 1'b1;
                index <= 4'd0;
                ready <= 1'b1;
            end
        end
    end
endmodule