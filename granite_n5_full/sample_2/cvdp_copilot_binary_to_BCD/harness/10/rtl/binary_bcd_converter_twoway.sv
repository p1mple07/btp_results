module binary_bcd_converter_twoway #(parameter BCD_DIGITS = 3, INPUT_WIDTH = 9) (
    input logic switch,
    input logic [(BCD_DIGITS*4)-1:0] bcd_in,
    output logic [(INPUT_WIDTH-1):0] binary_out,
    input logic [(INPUT_WIDTH-1):0] binary_in
);

    // Switch between binary-to-BCD and BCD-to-binary conversions based on the input `switch`.
    assign binary_out = switch? binary_bcd_conversion(bcd_in) : bcd_binary_conversion(binary_in);

    // Function to convert binary input to BCD output.
    function automatic logic [(BCD_DIGITS*4)-1:0] binary_bcd_conversion(logic [(INPUT_WIDTH-1):0] binary_in);
        logic [(BCD_DIGITS*4)-1:0] bcd_out;

        for (int i = (BCD_DIGITS*4)-1; i >= 0; i = i - 4) begin
            bcd_out[i:i-4] = binary_in[i:i-4] & 0x0f;
        end

        return bcd_out;
    endfunction

    // Function to convert BCD input to binary output.
    function automatic logic [(INPUT_WIDTH-1):0] bcd_binary_conversion(logic [(BCD_DIGITS*4)-1:0] bcd_in);
        logic [(INPUT_WIDTH-1):0] binary_out;
        logic [(BCD_DIGITS*4)-1:0] accu_binary_value;

        accu_binary_value = 0;

        for (int i = (BCD_DIGITS*4)-1; i >= 0; i = i - 4) begin
            accu_binary_value = (accu_binary_value * 1010) + bcd_in[i:i-4];
        end

        return accu_binary_value;
    endfunction

endmodule