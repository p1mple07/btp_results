module binary_bcd_converter_twoway #(
    parameter BCD_DIGITS = 3,
    parameter INPUT_WIDTH = 9
) (
    input logic [7:0] bcd_in,
    input logic [INPUT_WIDTH-1:0] binary_in,
    input logic switch,
    output logic [INPUT_WIDTH-1:0] binary_out,
    output logic [7:0] bcd_out
);

    logic [7:0] shift_reg;
    logic [BINARY_IN_BITS-1:0] binary_bits;
    logic [BCD_DIGITS-1:0] bcd_bits;
    logic [7:0] temp;

    initial begin
        // Initialize shift register for binary‑to‑BCD
        if (switch == 1) begin
            shift_reg = binary_in;
        end
        else begin
            shift_reg = {BCD_DIGITS*4{1'b0}};
        end

        // Directional processing
        always_comb begin
            if (switch == 1) begin
                // Binary → BCD
                for (int i = 0; i < BCD_DIGITS; i++) begin
                    temp = shift_reg << 1;
                    if (temp[11:8] >= 5) temp[11:8] = temp[11:8] + 3;
                    if (temp[15:12] >= 5) temp[15:12] = temp[15:12] + 3;
                    if (temp[19:16] >= 5) temp[19:16] = temp[19:16] + 3;
                    shift_reg = temp;
                end
                bcd_out = shift_reg[11:8];
            end
            else begin
                // BCD → Binary
                for (int i = 0; i < BCD_DIGITS; i++) begin
                    bcd_in = bcd_in[4*i];
                    binary_out[4*i+3:4*i] = bcd_in;
                end
            end
        end
    end

endmodule
