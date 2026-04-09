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
    // Process all characters in parallel
    always @(*) begin
        if (start && !reset) begin
            // Calculate ASCII values for all characters
            integer ascii_values[8] = 0;
            
            for (integer i = 0; i < 8; i = i + 1) begin
                char_type = determine_char_type(char_in[i]);
                case (char_type)
                    DIGIT: ascii_values[i] = char_in[i] + DIGIT_OFFSET;
                    UPPER: ascii_values[i] = (char_in[i] - 8'd10) + UPPER_OFFSET;
                    LOWER: ascii_values[i] = (char_in[i] - 8'd36) + LOWER_OFFSET;
                    SPECIAL: ascii_values[i] = (char_in[i] - 8'd62) + SPECIAL_OFFSET;
                    default: ascii_values[i] = 8'd0;
                endcase
            end

            ascii_out = ascii_values[0:7];
            valid = 1;
            ready = 1;
        end else begin
            ascii_out = 8'd0;
            valid = 0;
            ready = 0;
        end
    end
endmodule