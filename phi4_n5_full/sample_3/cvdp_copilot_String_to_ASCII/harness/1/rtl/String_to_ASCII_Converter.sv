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

    // Function to determine character type
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

    // Temporary storage for computed ASCII values (all computed in parallel)
    reg [7:0] temp_ascii_out [7:0];

    // Combinational conversion logic for each character
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : conv_loop
            always @(*) begin
                case (determine_char_type(char_in[i]))
                    DIGIT:   temp_ascii_out[i] = char_in[i] + DIGIT_OFFSET;
                    UPPER:   temp_ascii_out[i] = (char_in[i] - 8'd10) + UPPER_OFFSET;
                    LOWER:   temp_ascii_out[i] = (char_in[i] - 8'd36) + LOWER_OFFSET;
                    SPECIAL: temp_ascii_out[i] = (char_in[i] - 8'd62) + SPECIAL_OFFSET;
                    default: temp_ascii_out[i] = 8'd0;
                endcase
            end
        end
    endgenerate

    // State machine to latch conversion result in one cycle and then clear outputs
    reg state;
    localparam IDLE     = 1'b0;
    localparam CONVERT  = 1'b1;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state   <= IDLE;
            valid   <= 1'b0;
            ready   <= 1'b1;
            integer j;
            for (j = 0; j < 8; j = j + 1) begin
                ascii_out[j] <= 8'd0;
            end
        end else begin
            case (state)
                IDLE: begin
                    if (start && ready) begin
                        state   <= CONVERT;
                        valid   <= 1'b1;
                        ready   <= 1'b0;
                        integer k;
                        for (k = 0; k < 8; k = k + 1) begin
                            ascii_out[k] <= temp_ascii_out[k];
                        end
                    end else begin
                        valid   <= 1'b0;
                        ready   <= 1'b1;
                    end
                end
                CONVERT: begin
                    // Latch the conversion result for one cycle then clear outputs
                    state   <= IDLE;
                    valid   <= 1'b0;
                    ready   <= 1'b1;
                    integer m;
                    for (m = 0; m < 8; m = m + 1) begin
                        ascii_out[m] <= 8'd0;
                    end
                end
            endcase
        end
    end

endmodule