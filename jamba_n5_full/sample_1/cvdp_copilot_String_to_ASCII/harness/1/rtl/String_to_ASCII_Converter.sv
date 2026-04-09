module String_to_ASCII_Converter (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [7:0] char_in [7:0],
    output reg [7:0] ascii_out,
    output reg valid,
    output reg ready,
    output reg ready_deasserted
);

    localparam DIGIT   = 2'd0;
    localparam UPPER   = 2'd1;
    localparam LOWER   = 2'd2;
    localparam SPECIAL = 2'd3;

    reg [3:0] index;
    reg active;
    reg [1:0] char_type;
    reg [7:0] intermediate_ascii;

    // --- State machine transitions ------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            index   <= 4'd0;
            ascii_out   <= 8'd0;
            valid       <= 1'b0;
            ready       <= 1'b1;
        end else begin
            if (start) begin
                ready <= 1'b1;
                active <= 1'b1;
                index   <= 4'd0;
                valid   <= 1'b0;
            end else begin
                ready <= 1'b0;
            end
        end
    end

    // --- Convolution of characters ----------------------------------
    always @(active) begin
        if (active) begin
            ascii_values = 8'd0;
            for (integer i = 0; i < 8; i = i + 1) begin
                if (char_in[i]) begin
                    case (determine_char_type(char_in[i]))
                        DIGIT:   ascii_values = ascii_values + DIGIT_OFFSET + (char_in[i] - 8'd0);
                        UPPER:   ascii_values = ascii_values + UPPER_OFFSET + (char_in[i] - 8'd10);
                        LOWER:   ascii_values = ascii_values + LOWER_OFFSET + (char_in[i] - 8'd36);
                        SPECIAL: ascii_values = ascii_values + SPECIAL_OFFSET + (char_in[i] - 8'd62);
                    end
                end
            end
        end
    end

    // --- Output latch -------------------------------------------------
    always @(posedge clk) begin
        if (valid) begin
            ascii_out   = ascii_values;
            valid        <= 1'b1;
        end
    end

endmodule
