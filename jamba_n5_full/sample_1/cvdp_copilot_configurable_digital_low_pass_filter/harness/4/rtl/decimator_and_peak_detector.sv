module advanced_decimator_with_adaptive_peak_detection #(
    parameter INT_TYPE N = 8,
    parameter INT_TYPE DATA_WIDTH = 16,
    parameter INT_TYPE DEC_FACTOR = 4
) (
    input clk,
    input reset,
    input [3:0] data_in_addr,
    input valid_in,
    input [3:0] data_in,
    input [3:0] N,
    input [3:0] DATA_WIDTH,
    input [3:0] DEC_FACTOR
);

reg [DATA_WIDTH - 1:0] decimated_samples;
reg [DATA_WIDTH * (N / DEC_FACTOR) - 1:0] decimated_packed;
reg [DATA_WIDTH - 1:0] peak_value;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        decimated_samples <= {0};
        decimated_packed <= 0;
        peak_value <= 0;
    end else begin
        if (valid_in) begin
            // Unpack the packed input into individual samples
            for (int i = 0; i < N; i++) begin
                decimated_samples[i] = data_in[i];
            end
        end else begin
            decimated_samples <= {0};
        end
    end
end

// Decimation: keep every DEC_FACTOR‑th sample
for (int i = 0; i < N / DEC_FACTOR; i++) begin
    decimated_packed[i * DATA_WIDTH] = decimated_samples[i];
end

// Find the maximum value in the decimated data
peak_value = decimated_packed[0];
for (int i = 1; i < decimated_packed.size(); i++) begin
    if (decimated_packed[i] > peak_value) begin
        peak_value = decimated_packed[i];
    end
end

// Output the packed decimated data and the peak
assign data_out = decimated_packed;
assign valid_out = valid_in;
assign peak_value = peak_value;

endmodule
