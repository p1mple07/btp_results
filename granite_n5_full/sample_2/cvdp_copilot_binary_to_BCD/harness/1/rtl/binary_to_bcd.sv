module binary_to_bcd(
    input logic [7:0] binary_in,  // 8-bit binary input
    output logic [11:0] bcd_out   // 12-bit BCD output (3 digits)
);
    // Intermediate shift register to hold binary and BCD values
    logic [19:0] shift_reg;  // 20-bit register: 12 for BCD and 8 for binary input
    integer I;

    // Insert code here for Double Dabble algorithm
    always_comb begin
    // Step 1: Initialize the shift register
    shift_reg = {12'd0, binary_in}; 

    // Step 2: Insert code here for Double Dabble algorithm
    // e.g.
    //   1. a binary number to be converted to ASCII files and
    //   2. a BCD number to be converted to ASCII files
    //   3. a BCD number to be converted to ASCII files
    // 
    bcd_out = shift_reg[19:0] ;

endmodule