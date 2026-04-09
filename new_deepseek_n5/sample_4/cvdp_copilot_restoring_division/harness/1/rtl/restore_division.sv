module restoring_division (
    parameter WIDTH,
    input clock,
    input rst,
    input start,
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divisor,
    output [WIDTH-1:0] quotient,
    output [WIDTH-1:0] remainder,
    output valid
);

    // Initialize the remainder to zero
    reg [WIDTH-1:0] remainder = 0;
    // Quotient will be built bit by bit
    reg [WIDTH-1:0] quotient = 0;
    // Control signals for the algorithm
    reg start_algorithm;
    reg valid;
    // Internal signals for the algorithm
    reg [WIDTH:0] partial_remainder;
    reg [WIDTH-1:0] quotient_bit;
    reg [WIDTH-1:0] difference;
    reg borrow;

    // Clock enablement for the algorithm
    always positive edge clock'edge begin
        if (rst) begin
            remainder = 0;
            quotient = 0;
            valid = 0;
            partial_remainder = 0;
            quotient_bit = 0;
            difference = 0;
            borrow = 0;
        end else if (start && valid) begin
            // Process one bit of the dividend
            partial_remainder = (remainder << 1) | (dividend[0]);
            difference = partial_remainder - divisor;
            borrow = (difference >> (WIDTH)) & 1;
            if (borrow) begin
                // Subtraction resulted in negative, restore remainder
                remainder = (partial_remainder - divisor) >> 1;
                quotient_bit = 0;
            else begin
                // Subtraction was successful, keep remainder
                remainder = difference;
                quotient_bit = 1;
            end
            // Shift the quotient left and append new bit
            quotient = (quotient << 1) | quotient_bit;
            // Prepare for next iteration
            partial_remainder = remainder;
            quotient_bit = 0;
            difference = 0;
            borrow = 0;
        end
    end

    // After WIDTH iterations, set valid to indicate completion
    integer iterations = 0;
    always begin
        if (rst) begin
            valid = 0;
        end else if (start) begin
            if (iterations < WIDTH) begin
                iterations = iterations + 1;
            end else begin
                valid = 1;
            end
        end
    end

    // Output the results
    assign quotient = quotient;
    assign remainder = remainder;
    assign valid = valid;

endmodule