module advanced_decimator_with_adaptive_peak_detection (
    input clock,
    input reset,
    input valid_in,
    input data_in,
    output valid_out,
    output data_out,
    output peak_value
);

    // Phase 1: Initialize peak and start processing
    always clock_edge begin
        if (reset) begin
            // Initialize decimated data register
            decimated_data <= (data_in >> (N * DATA_WIDTH)) << (N * DATA_WIDTH);
            
            // Initialize peak with first sample
            peak_value <= data_in;
            valid_out <= 0;
        end else begin
            // Process decimation and peak detection
            // Unpack data_in into individual samples
            for (int i = 0; i < N; i++) begin
                sample_data[i] <= (data_in >> (i * DATA_WIDTH)) & ((1 << DATA_WIDTH) - 1);
            end

            // Decimate data
            for (int i = 0; i < (N / DEC_FACTOR); i++) begin
                decimated_samples[i] <= sample_data[i * DEC_FACTOR];
            end

            // Find peak in decimated samples
            for (int i = 1; i < (N / DEC_FACTOR); i++) begin
                if (decimated_samples[i] > peak_value) begin
                    peak_value <= decimated_samples[i];
                end
            end

            // Pack decimated samples
            data_out <= 0;
            for (int i = 0; i < (N / DEC_FACTOR); i++) begin
                data_out <= (data_out << (DATA_WIDTH)) | decimated_samples[i];
            end

            // Set valid_out
            valid_out <= 1;
        end
    end

    // Phase 2: Continue processing
    always clock_edge begin
        if (!reset) begin
            // Update decimated samples
            for (int i = (N / DEC_FACTOR); i < N; i++) begin
                decimated_samples[i / DEC_FACTOR] <= sample_data[i];
            end

            // Update peak value
            for (int i = (N / DEC_FACTOR); i < (N / DEC_FACTOR); i++) begin
                if (decimated_samples[i] > peak_value) begin
                    peak_value <= decimated_samples[i];
                end
            end

            // Pack decimated samples
            for (int i = (N / DEC_FACTOR); i < (N / DEC_FACTOR); i++) begin
                data_out <= (data_out << (DATA_WIDTH)) | decimated_samples[i];
            end

            // Set valid_out
            valid_out <= 1;
        end
    end

    // Register for decimated samples
    bit [N*DATA_WIDTH-1:0] decimated_samples[(N/DEC_FACTOR)-1:0];
    bit [DATA_WIDTH-1:0] peak_value;

    // Unpack data into samples
    bit [DATA_WIDTH-1:0] sample_data[N-1:0];

endmodule