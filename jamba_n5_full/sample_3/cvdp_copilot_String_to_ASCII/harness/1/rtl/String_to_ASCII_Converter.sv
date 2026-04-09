module String_to_ASCII_Converter (
    input wire clk,                       // Clock signal
    input wire reset,                     // Reset signal
    input wire start,                     // Start conversion
    input wire [7:0] char_in [7:0],       // 8‑character input string (7 bits per character: 0‑95)
    output reg [7:0] ascii_out,           // Final latched ASCII output
    output reg valid,                     // Indicates valid output
    output reg ready,                     // Indicates module ready to accept input
);

    localparam DIGIT   = 2'd0;
    localparam UPPER   = 2'd1;
    localparam LOWER   = 2'd2;
    localparam SPECIAL = 2'd3;

    localparam DIGIT_OFFSET   = 8'd48;
    localparam UPPER_OFFSET   = 8'd65;
    localparam LOWER_OFFSET   = 8'd97;
    localparam SPECIAL_OFFSET = 8'd33;

    reg [3:0] index;
    reg active;
    reg [1:0] char_type;
    reg [7:0] intermediate_ascii;

    function [1:0] determine_char_type(input [7:0] ch);
        begin
            if (ch < 8'd10)
                return DIGIT;
            else if (ch < 8'd36)
                return UPPER;
            else if (ch < 8'd62)
                return LOWER;
            else
                return SPECIAL;
        end
    endfunction

    always @(*, posedge clk, posedge reset) begin
        if (reset) begin
            index       <= 4'd0;
            ascii_out   <= 8'd0;
            valid       <= 1'b0;
            ready       <= 1'b1;
            active      <= 1'b0;
        end else begin
            if (start && ready) begin
                ready <= 1'b0;
                active <= 1'b1;
                index <= 4'd0;
            end else if (active) begin
                // Process the current character
                intermediate_ascii = 0;
                case (char_type)
                    DIGIT:   intermediate_ascii = char_in[index] + DIGIT_OFFSET;
                    UPPER:   intermediate_ascii = (char_in[index] - 8'd10) + UPPER_OFFSET;
                    LOWER:   intermediate_ascii = (char_in[index] - 8'd36) + LOWER_OFFSET;
                    SPECIAL: intermediate_ascii = (char_in[index] - 8'd62) + SPECIAL_OFFSET;
                    default: intermediate_ascii = 8'd0;
                endcase

                // Assign all eight values in parallel
                ascii_out = {
                    intermediate_ascii[0],
                    intermediate_ascii[1],
                    intermediate_ascii[2],
                    intermediate_ascii[3],
                    intermediate_ascii[4],
                    intermediate_ascii[5],
                    intermediate_ascii[6],
                    intermediate_ascii[7]
                };

                valid <= 1'b1;
                index <= index + 1;
            end
        end
    end

endmodule
