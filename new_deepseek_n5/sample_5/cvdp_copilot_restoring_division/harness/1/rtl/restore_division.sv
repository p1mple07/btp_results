module restoring_division (
    input wire [WIDTH-1:0] dividend,
    input wire [WIDTH-1:0] divisor,
    input wire clk,
    input wire rst,
    input wire start,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output reg valid
);

    // Initialize remainder to 0
    reg [WIDTH-1:0] remainder = 0;

    // Quotient will be built bit by bit
    reg [WIDTH-1:0] quotient = 0;

    // Control signals for the algorithm
    reg start_new_iteration = 0;
    reg valid_after_iteration = 0;

    // Subtractor component
    subtractor subtractor (
        .a(remainder),
        .b(divisor),
        .valid(valid_after_iteration),
        .result(remainder)
    );

    // Main loop for division
    always_comb begin
        if (rst) begin
            // Reset all outputs
            remainder = 0;
            quotient = 0;
            valid = 0;
            // Wait for start to begin the process
            valid_after_iteration = 0;
        elsif start begin
            // Start the division process
            start_new_iteration = 1;
            valid = 0;
        end

        // Perform WIDTH iterations
        for (int i = 0; i < WIDTH; i = i + 1) begin
            // Shift remainder left and add next bit from dividend
            remainder = (remainder << 1) | (dividend >> (WIDTH - 1 - i)) & 1;
            
            // Subtract divisor and check result
            if (remainder >= divisor) begin
                // Quotient bit is 1
                quotient = quotient | (1 << (WIDTH - 1 - i));
                // Keep the result as new remainder
            else begin
                // Quotient bit is 0
                // Restore remainder by dropping the quotient bit
                remainder = remainder >> 1;
            end

            // Update validity after iteration
            valid_after_iteration = 1;
        end

        // After WIDTH iterations, set valid
        valid = valid_after_iteration;
    end

    // Cleanup after division
    always_comb begin
        if (rst) begin
            // Cleanup
            valid = 0;
        end
    end
endmodule