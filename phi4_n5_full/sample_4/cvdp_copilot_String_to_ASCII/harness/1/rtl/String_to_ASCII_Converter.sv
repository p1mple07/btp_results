module String_to_ASCII_Converter (
    input  wire         clk,             // Clock signal
    input  wire         reset,           // Reset signal
    input  wire         start,           // Start conversion
    input  wire [7:0]   char_in [7:0],   // 8-character input string (custom encoded)
    output reg  [7:0]   ascii_out [7:0], // ASCII output for each character
    output reg          valid,           // Conversion valid
    output reg          ready            // Ready for new conversion
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
    localparam SPECIAL_OFFSET = 8'd33;    // '!' = 33

    //--------------------------------------------------------------------------
    // Combinational Conversion Logic
    // For each input character, determine its type and compute the corresponding
    // ASCII value. All 8 conversions are done in parallel.
    //--------------------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : conv_loop
            // Determine character type based on the custom encoding.
            // Digits: 0-9 (values 0-9)
            // Uppercase: A-Z (values 10-35)
            // Lowercase: a-z (values 36-61)
            // Special: !-@ (values 62-95)
            wire [1:0] char_type;
            assign char_type = (char_in[i] < 8'd10)    ? DIGIT  :
                               (char_in[i] < 8'd36)    ? UPPER  :
                               (char_in[i] < 8'd62)    ? LOWER  : SPECIAL;

            // Compute the ASCII value based on the character type.
            wire [7:0] ascii_val;
            assign ascii_val = (char_type == DIGIT)   ? (char_in[i] + DIGIT_OFFSET)   :
                               (char_type == UPPER)   ? ((char_in[i] - 8'd10) + UPPER_OFFSET)   :
                               (char_type == LOWER)   ? ((char_in[i] - 8'd36) + LOWER_OFFSET)   :
                               (char_type == SPECIAL) ? ((char_in[i] - 8'd62) + SPECIAL_OFFSET) : 8'd0;

            // Latch the computed value into an intermediate wire array.
            // (We use the same index i for each conversion.)
            // Note: We use a separate generate block below to collect all computed values.
        end
    endgenerate

    // Collect all computed ASCII values into a wire array.
    // (This array is computed in parallel by the above generate block.)
    wire [7:0] ascii_conv [7:0];
    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : collect_conv
            // Replicate the conversion logic for each character.
            wire [1:0] conv_type;
            assign conv_type = (char_in[j] < 8'd10)    ? DIGIT  :
                               (char_in[j] < 8'd36)    ? UPPER  :
                               (char_in[j] < 8'd62)    ? LOWER  : SPECIAL;
            wire [7:0] conv_val;
            assign conv_val = (conv_type == DIGIT)   ? (char_in[j] + DIGIT_OFFSET)   :
                               (conv_type == UPPER)   ? ((char_in[j] - 8'd10) + UPPER_OFFSET)   :
                               (conv_type == LOWER)   ? ((char_in[j] - 8'd36) + LOWER_OFFSET)   :
                               (conv_type == SPECIAL) ? ((char_in[j] - 8'd62) + SPECIAL_OFFSET) : 8'd0;
            assign ascii_conv[j] = conv_val;
        end
    endgenerate

    //--------------------------------------------------------------------------
    // Sequential Logic: Latch the parallel conversion result.
    // When start is asserted (and the module is ready), the entire 8-character
    // conversion is latched into ascii_out in one clock cycle.
    // After latching, valid is asserted and ready is deasserted.
    // In the next cycle, valid is cleared, ready is asserted, and ascii_out is reset.
    //--------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ascii_out <= '0;
            valid     <= 1'b0;
            ready     <= 1'b1;
        end
        else if (start && ready) begin
            // Latch the entire conversion result in one cycle.
            ascii_out <= ascii_conv;
            valid     <= 1'b1;
            ready     <= 1'b0;
        end
        else if (valid) begin
            // After one cycle, deassert valid and reassert ready.
            // Also, reset ascii_out to ensure proper initialization.
            valid     <= 1'b0;
            ready     <= 1'b1;
            ascii_out <= '0;
        end
    end

endmodule