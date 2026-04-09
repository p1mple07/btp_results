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

    localparam CHAR_MASK = 8'hFF; // Mask for special characters

    reg [3:0] index;
    reg active;
    reg [1:0] char_type;
    reg [7:0] intermediate_ascii;

    function [1:0] determine_char_type(input bitstream);
        begin
            if (char_in < 8'd10)
                return DIGIT;
            else if (char_in < 8'd36)
                return UPPER;
            else if (char_in < 8'd62)
                return LOWER;
            else
                return SPECIAL;
        end
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            index <= 4'd0;
            ascii_out <= 8'd0;
            valid <= 1'b0;
            ready <= 1'b1;
            active <= 1'b0;
        end else begin
            if (start && ready) begin
                ready <= 1'b0;
                active <= 1'b1;
                index <= 4'd0;
                valid <= 1'b0;
            end else if (active) begin
                for (int i = 0; i < 8; i++) begin
                    ascii_out[i] <= intermediate_ascii;
                end
                valid <= 1'b1;
                ready <= 1'b1;
            end
        end
    end

endmodule
