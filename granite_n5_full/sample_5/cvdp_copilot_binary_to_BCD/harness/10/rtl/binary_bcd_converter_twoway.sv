module binary_bcd_converter_twoway #(
    parameter BCD_DIGITS = 3,
    parameter INPUT_WIDTH = 9
)(
    input logic switch,  // Selects between binary-to-BCD and BCD-to-binary conversions
    input logic [(BCD_DIGITS*4)-1:0] bcd_in,  // BCD input value
    input logic [INPUT_WIDTH-1:0] binary_in,  // Binary input value
    output logic [INPUT_WIDTH-1:0] binary_out,  // Binary output value
    output logic [(BCD_DIGITS*4)-1:0] bcd_out  // BCD output value
);

    // Binary-to-BCD conversion logic
    always_comb begin
        if (switch == 1'b0) begin
            binary_out = 0;
            for (int i = BCD_DIGITS-1; i >= 0; i--) begin
                binary_out = (binary_out << 4) + bcd_in[i*4:(i*4)+4];
            end
        end else begin
            bcd_out = 0;
            for (int i = BCD_DIGITS-1; i >= 0; i--) begin
                bcd_out = (bcd_out << 4) + binary_in[i];
            end
        end
    end

endmodule