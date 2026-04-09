module advanced_decimator_with_adaptive_peak_detection #(
    parameter N = 8,
    parameter DATA_WIDTH = 16,
    parameter DEC_FACTOR = 4
)(
    input wire clk,
    input wire reset,
    input wire valid_in,
    input data_in #bit[],
    output wire valid_out,
    output wire [DATA_WIDTH*N/DEC_FACTOR:0] data_out,
    output wire peak_value
);

// Reset handling
always_ff @(active low clk) begin
    if (~reset) begin
        valid_out <= 0;
        data_out <= 0;
        peak_value <= 0;
    end else begin
        // Unpack input data
        wire [DATA_WIDTH*N/DEC_FACTOR - 1:0] decimated;

        // Iterate over decimated samples
        for (int i = 0; i < N / DEC_FACTOR; i++) begin
            decimated[i*DATA_WIDTH : (i+1)*DATA_WIDTH - 1] = data_in[i];
        end

        // Compute peak
        wire peak = decimated[0];
        for (int i = 1; i < N/DEC_FACTOR; i++) begin
            if (decimated[i*DATA_WIDTH] > peak)
                peak = decimated[i*DATA_WIDTH];
        end

        // Pack output data
        for (int i = 0; i < N / DEC_FACTOR; i++) begin
            data_out[i*DATA_WIDTH : (i+1)*DATA_WIDTH - 1] = decimated[i*DATA_WIDTH : (i+1)*DATA_WIDTH - 1];
        end

        // Peak value
        peak_value = peak;
    end
end

// Clock enable for sampling
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        // Do nothing, but reset all outputs
    end else begin
        valid_out = 1;
        data_out = decimated;
        peak_value = peak;
    end
end

endmodule
