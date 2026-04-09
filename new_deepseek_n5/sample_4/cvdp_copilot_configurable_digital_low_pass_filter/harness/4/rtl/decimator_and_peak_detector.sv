module advanced_decimator_with_adaptive_peak_detection(
    input clock,
    input reset,
    input valid_in,
    input [DATA_WIDTH * N] data_in,
    output [DATA_WIDTH * (N / DEC_FACTOR)] data_out,
    output peak_value,
    output valid_out
);

    // unpack input data into individual samples
    reg [DATA_WIDTH] samples[N];
    integer i, j;

    // initialize decimated samples
    reg [DATA_WIDTH] decimated_samples[N / DEC_FACTOR];

    // unpack data_in into samples
    for (i = 0; i < N; i++) begin
        samples[i] = data_in[(DATA_WIDTH * i)];
    end

    // decimate samples
    for (i = 0; i < N / DEC_FACTOR; i++) begin
        decimated_samples[i] = samples[i * DEC_FACTOR];
    end

    // find peak value
    reg [DATA_WIDTH] current_peak;
    current_peak = decimated_samples[0];
    for (i = 1; i < N / DEC_FACTOR; i++) begin
        if (decimated_samples[i] > current_peak) begin
            current_peak = decimated_samples[i];
        end
    end
    peak_value = current_peak;

    // pack decimated samples into data_out
    data_out = (peak_value) |
               (decimated_samples[0] << DATA_WIDTH) |
               (decimated_samples[1] << (2 * DATA_WIDTH)) |
               // ... continue this pattern for all decimated samples
               (decimated_samples[N / DEC_FACTOR - 1] << ((N / DEC_FACTOR - 1) * DATA_WIDTH));

    // set valid_out based on valid_in and number of samples
    valid_out = valid_in & (N > 0);

endmodule