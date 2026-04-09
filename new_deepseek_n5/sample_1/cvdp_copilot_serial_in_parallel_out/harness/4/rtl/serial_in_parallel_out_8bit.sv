module serial_in_parallel_out_8bit(
    input clock,
    input serial_in,
    output parallel_out
);
    // Module for 8-bit SIPO shift register
    // shift_reg[0] is the LSB, shift_reg[7] is the MSB
    reg [7:0] shift_reg;
    // Initial value for shift_reg[0] to be 0
    shift_reg[0] = 0;
    // Assign new serial_in to LSB of shift_reg on positive clock edge
    positive_edge clock begin
        shift_reg[0] = serial_in;
        // Shift all bits to the left
        for (int i = 7; i > 0; i--)$shift_reg[i] = shift_reg[i-1];
    end
    // Assign parallel_out from shift_reg
    parallel_out = shift_reg;
endmodule