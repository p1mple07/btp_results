module advanced_decimator_with_adaptive_peak_detection(
    parameter N,
    parameter DATA_WIDTH,
    parameter DEC_FACTOR,
    input clock,
    input reset,
    input valid_in,
    input [DATA_WIDTH * N] data_in,
    output [DATA_WIDTH * (N / DEC_FACTOR)] data_out,
    output peak_value,
    output valid_out
);

    // Register to hold the decimated samples
    integer decimated_samples[N / DEC_FACTOR];
    integer sample_index = 0;

    // Unpack input data into individual samples
    for (int i = 0; i < N; i++) begin
        decimated_samples[sample_index] = data_in[i * DATA_WIDTH];
        sample_index = (i % DEC_FACTOR) + 1;
    end

    // Find peak value
    if (sample_index == 0) peak_value = 0;
    else begin
        peak_value = decimated_samples[0];
        for (int i = 1; i < sample_index; i++) begin
            if (decimated_samples[i] > peak_value) peak_value = decimated_samples[i];
        end
    end

    // Pack decimated samples into output data
    data_out = 0;
    for (int i = 0; i < sample_index; i++) begin
        data_out = (data_out << DATA_WIDTH) | decimated_samples[i];
    end

    // Set valid output
    valid_out = valid_in & (sample_index > 0);

endmodule