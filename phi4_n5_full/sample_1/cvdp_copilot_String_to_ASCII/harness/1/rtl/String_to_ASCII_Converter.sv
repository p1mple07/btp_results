module String_to_ASCII_Converter (
    input  wire         clk,
    input  wire         reset,
    input  wire         start,
    input  wire [7:0]   char_in [7:0],
    output reg  [7:0]   ascii_out [7:0],
    output reg          valid,
    output reg          ready
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
    localparam SPECIAL_OFFSET = 8'd33;   // '!' = 33

    // Internal temporary register to hold computed ASCII values for all 8 characters
    reg [7:0] ascii_temp [7:0];

    // Function to determine character type based on custom encoding
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

    // Combinational block to compute ASCII conversion for all characters in parallel
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            case (determine_char_type(char_in[i]))
                DIGIT:   ascii_temp[i] = char_in[i] + DIGIT_OFFSET;          // '0'-'9'
                UPPER:   ascii_temp[i] = (char_in[i] - 8'd10) + UPPER_OFFSET; // 'A'-'Z'
                LOWER:   ascii_temp[i] = (char_in[i] - 8'd36) + LOWER_OFFSET; // 'a'-'z'
                SPECIAL: ascii_temp[i] = (char_in[i] - 8'd62) + SPECIAL_OFFSET; // Special characters
                default: ascii_temp[i] = 8'd0;
            endcase
        end
    end

    // Sequential logic: Latch computed ASCII values in one clock cycle when start is asserted.
    // When processing is complete, valid is deasserted and ready is reasserted.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid  <= 1'b0;
            ready  <= 1'b1;
            integer j;
            for (j = 0; j < 8; j = j + 1)
                ascii_out[j] <= 8'd0;
        end else begin
            if (start && ready) begin
                // Latch the complete conversion result in one cycle.
                for (i = 0; i < 8; i = i + 1)
                    ascii_out[i] <= ascii_temp[i];
                valid <= 1'b1;
                ready <= 1'b0;
            end else if (!start) begin
                // Processing complete: deassert valid and reassert ready.
                // Optionally, clear ascii_out for proper initialization of subsequent operations.
                for (i = 0; i < 8; i = i + 1)
                    ascii_out[i] <= 8'd0;
                valid <= 1'b0;
                ready <= 1'b1;
            end
        end
    end

endmodule