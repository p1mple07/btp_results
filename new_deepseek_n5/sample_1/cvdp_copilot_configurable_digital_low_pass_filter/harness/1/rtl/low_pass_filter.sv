module low_pass_filter(
    input clock,
    input reset,
    input data_in,
    input valid_in,
    input coeffs,
    output data_out,
    output valid_out
);

    // Internal signals
    reg data_reg[NUM_TAPS][DATA_WIDTH];
    reg coeff_reg[NUM_TAPS][COEFF_WIDTH];
    reg temp_mult[NUM_TAPS];
    reg sum_result;
    reg valid_reg;

    // unpack data_in
    integer i, j;
    initial begin
        // Initialize all registers to 0
        data_reg[0][0] = 0;
        coeff_reg[0][0] = 0;
    end

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            // Clear all registers
            data_reg[0][0] = 0;
            coeff_reg[0][0] = 0;
            temp_mult[0] = 0;
            sum_result = 0;
            valid_reg = 0;
        end else begin
            // Store data_in and coeffs
            data_reg[0][0] = data_in;
            coeff_reg[0][0] = coeffs[0];
            valid_reg = valid_in;

            // Unpack data and coeffs
            for (i = 0; i < NUM_TAPS; i++) begin
                for (j = 0; j < DATA_WIDTH; j++) begin
                    data_reg[i][j] = (data_in >> (NUM_TAPS * DATA_WIDTH - 1 - i * DATA_WIDTH - j)) & ((1 << DATA_WIDTH) - 1);
                end
            end

            for (i = 0; i < NUM_TAPS; i++) begin
                for (j = 0; j < COEFF_WIDTH; j++) begin
                    coeff_reg[i][j] = (coeffs[i] >> (COEFF_WIDTH - 1 - j)) & ((1 << COEFF_WIDTH) - 1);
                end
            end

            // Element-wise multiplication
            for (i = 0; i < NUM_TAPS; i++) begin
                temp_mult[i] = data_reg[i][0] * coeff_reg[i][0];
            end

            // Summation
            sum_result = 0;
            for (i = 0; i < NUM_TAPS; i++) begin
                sum_result = sum_result + temp_mult[i];
            end

            // Pack result
            data_out = sum_result;
        end
    end

    // Output validity
    valid_out = valid_reg;

endmodule