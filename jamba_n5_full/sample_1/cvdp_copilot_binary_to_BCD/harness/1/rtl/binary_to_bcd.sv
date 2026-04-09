module binary_to_bcd (
    input logic [7:0] binary_in,  // 8-bit binary input
    output logic [11:0] bcd_out   // 12-bit BCD output (3 digits)
);

    logic [19:0] shift_reg;  // 20-bit register: 12 for BCD and 8 for binary input
    integer I;

    initial begin
        shift_reg = {12'd0, binary_in};  // Initialise with binary input in the LSB group
    end

    always_comb begin
        bcd_out = shift_reg[19:8];  // Extract the 12‑bit BCD result
    end

endmodule
