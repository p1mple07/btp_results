module restore_division(
    input clock,
    input rst,
    input start,
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divisor,
    output [WIDTH-1:0] quotient,
    output [WIDTH-1:0] remainder,
    output valid
);

    // Initialize registers
    reg [WIDTH-1:0] remainder = 0;
    reg [WIDTH-1:0] dividend_reg = dividend;
    reg [WIDTH-1:0] quotient = 0;
    reg [WIDTH-1:0] temp;

    // Loop for each bit of the result
    for (int i = 0; i < WIDTH; i++) {
        // Shift remainder left and add next bit from dividend
        remainder = (remainder << 1) | (dividend_reg >> WIDTH)[WIDTH-1];
        
        // Subtract divisor and check result
        temp = remainder - divisor;
        if (temp >= 0) {
            // If result is positive, keep remainder and set quotient bit
            remainder = temp;
            quotient = quotient | (1 << (WIDTH - 1 - i));
        } else {
            // If result is negative, restore remainder
            remainder = 0;
        }
    }

    // Set valid after computation
    valid = 1;

    // Reset if reset is asserted
    if (rst) {
        quotient = 0;
        remainder = 0;
        valid = 0;
    }

endmodule