module advanced_decimator_with_adaptive_peak_detection (
    input wire clk,
    input wire reset,
    input wire valid_in,
    input [DATA_WIDTH-1:0] data_in,
    input wire valid_out,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg [DATA_WIDTH-1:0] peak_value
);

    // Parameters
    localparam DEC_FACTOR = 4;
    localparam N = 8;
    localparam DATA_WIDTH = 16;

    // Internal registers
    reg [DATA_WIDTH-1:0] decimated_samples;
    reg [DATA_WIDTH-1:0] decimated_value;
    reg [DATA_WIDTH-1:0] decimated_max;
    reg valid_out_internal;

    // Always blocks for reset handling
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            decimated_samples <= 0;
            decimated_value <= 0;
            decimated_max <= 0;
            valid_out_internal <= 1'b0;
        end else begin
            valid_out_internal <= valid_in;
        end
    end

    // Decimation logic
    always @(posedge clk) begin
        if (valid_out_internal) begin
            decimated_samples = {};
            for (integer i = 0; i < N / DEC_FACTOR; i++) begin
                decimated_samples.push(data_in[(i * DEC_FACTOR) + i]);
            end
            decimated_value = decimated_samples[DEC_SAMPLES_COUNT - 1];
            decimated_max = decimated_value;
            for (integer j = 0; j < N / DEC_FACTOR - 1; j++) begin
                if (decimated_samples[j] > decimated_max) decimated_max = decimated_samples[j];
            end
        end
    end

    // Pack data output
    always @(posedge clk) begin
        data_out = {};
        for (integer i = 0; i < N / DEC_FACTOR; i++) begin
            data_out.push(decimated_samples[i]);
        end
    end

    // Peak detection
    always @(*) begin
        peak_value = decimated_max;
    end

endmodule
