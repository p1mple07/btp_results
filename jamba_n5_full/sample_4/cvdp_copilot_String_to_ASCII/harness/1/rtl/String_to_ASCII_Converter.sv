module String_to_ASCII_Converter (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [7:0] char_in [7:0],
    output reg [7:0] ascii_out,
    output reg valid,
    output reg ready
);
    localparam DIGIT   = 2'd0;
    localparam UPPER   = 2'd1;
    localparam LOWER   = 2'd2;
    localparam SPECIAL = 2'd3;
    localparam DIGIT_OFFSET   = 8'd48;    // '0' = 48
    localparam UPPER_OFFSET   = 8'd65;    // 'A' = 65
    localparam LOWER_OFFSET   = 8'd97;    // 'a' = 97
    localparam SPECIAL_OFFSET = 8'd33;   // First special character '!' = 33

    reg [3:0] index;                      // Index for current character
    reg active;                           // Indicates active conversion
    reg [1:0] char_type;                  // Current character type
    reg [7:0] intermediate_ascii;         // Combinational ASCII value
    reg [7:0] ascii_out;                  // Final latched ASCII output
    reg valid;                             // Indicates valid output
    reg ready;                             // Indicates module ready to accept input

    function [1:0] determine_char_type;
        input [7:0] char;
        begin
            if (char < 8'd10)
                return DIGIT;    // '0'-'9'
            else if (char < 8'd36)
                return UPPER;    // 'A'-'Z'
            else if (char < 8'd62)
                return LOWER;    // 'a'-'z'
            else
                return SPECIAL;  // Special characters
        end
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            index <= 4'd0;
            ascii_out <= 8'd0;
            valid <= 1'b0;
            ready <= 1'b1;
        end else begin
            if (start && ready) begin
                // Process all 8 characters in one go
                for (int i = 0; i < 8; i++) begin
                    ascii_out[i] = char_in[i];
                end
                valid <= 1'b1;
                ready <= 1'b0;
            end
        end
    end
endmodule
