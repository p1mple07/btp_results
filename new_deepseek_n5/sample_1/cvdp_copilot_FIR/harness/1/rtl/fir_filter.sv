always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        sample_delay1 = 0;
        sample_delay2 = 0;
        sample_delay3 = 0;
        accumulator = 0;
        output_sample = 0;
    else begin
        // Compute term0: coeff0 * input_sample
        term0 = coeff0 * input_sample;
        accumulator = accumulator + term0;

        // Shift sample_delay1 to sample_delay2
        sample_delay1 = sample_delay2;

        // Compute term1: coeff1 * sample_delay2
        term1 = coeff1 * sample_delay2;
        accumulator = accumulator + term1;

        // Shift sample_delay2 to sample_delay3
        sample_delay2 = sample_delay3;

        // Compute term2: coeff2 * sample_delay3
        term2 = coeff2 * sample_delay3;
        accumulator = accumulator + term2;

        // Shift sample_delay3 to sample_delay4 (no register, so this is not needed)
        // Compute term3: coeff3 * sample_delay3
        term3 = coeff3 * sample_delay3;
        accumulator = accumulator + term3;

        // Assign output_sample after 4 clocks
        output_sample = accumulator;
    end
endmodule