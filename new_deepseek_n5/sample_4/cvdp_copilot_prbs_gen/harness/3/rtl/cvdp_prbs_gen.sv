module cvdp_prbs_gen(
    input clock,
    input rst,
    input [WIDTH-1:0] data_in,
    output [WIDTH-1:0] data_out
);

    // Configuration parameters
    parameter CHECK_MODE = 0;
    parameter POLY_LENGTH = 31;
    parameter POLY_TAP = 3;
    parameter WIDTH = 16;

    // LFSR state register
    reg [POLY_LENGTH-1:0] prbs_reg;

    // Expected PRBS pattern
    reg [POLY_LENGTH-1:0] expected_prbs;

    // Initialize on reset
    always_comb begin
        if (rst) begin
            prbs_reg = (1 << POLY_LENGTH) - 1;
            data_out = (1 << WIDTH) - 1;
        end
    end

    // Generate PRBS pattern
    always clocked begin
        if (rst) 
            prbs_reg = (1 << POLY_LENGTH) - 1;
        else
            // Calculate feedback bit
            bit feedback_bit;
            feedback_bit = 0;
            for (int i = 0; i < POLY_TAP; i++) begin
                feedback_bit = feedback_bit ^ (prbs_reg & (1 << (POLY_LENGTH - 1 - i)));
            end
            // Shift register right and insert feedback bit
            prbs_reg = prbs_reg >> 1;
            prbs_reg = prbs_reg | feedback_bit << (POLY_LENGTH - 1);
        end

        // Update data_out
        data_out = prbs_reg;
    end

    // Checker mode functionality
    if (CHECK_MODE) begin
        // Generate expected PRBS pattern
        expected_prbs = prbs_reg;
        // Compare with data_in
        data_out = data_in ^ expected_prbs;
    end
endmodule