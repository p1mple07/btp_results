module binary_bcd_converter_twoway #(
    parameter BCD_DIGITS = 3,
    parameter INPUT_WIDTH = 9
) (
    input wire switch,           // Switch between binary-to-BCD and BCD-to-binary conversions
    input wire [BCD_DIGITS*4-1:0] bcd_in,  // BCD input value
    input wire [INPUT_WIDTH-1:0] binary_in,  // Binary input value
    output wire [INPUT_WIDTH-1:0] binary_out,  // Binary output value
    output wire [BCD_DIGITS*4-1:0] bcd_out  // BCD output value
);

    localparam BINARY_TO_BCD_WIDTH = INPUT_WIDTH - BCD_DIGITS*4;

    always_comb begin
        if (switch == 1'b0) begin  // Convert binary to BCD
            binary_out = 0;
            for (int i = BCD_DIGITS-1; i >= 0; i--) begin
                binary_out = (binary_out << 4) | (binary_in[BINARY_TO_BCD_WIDTH+i]? i+4'b1000 : 4'b0);
            end
        end else begin  // Convert BCD to binary
            bcd_out = 0;
            for (int i = BCD_DIGITS-1; i >= 0; i--) begin
                bcd_out = (bcd_out << 4) | (bcd_in[i*4+(BCD_DIGITS*4-1):i*4]? i+4'b1000 : 4'b0);
            end
        end
    end

endmodule