module advanced_decimator_with_adaptive_peak_detection #(
    parameter int N = 8,
    parameter int DATA_WIDTH = 16,
    parameter int DEC_FACTOR = 4
) (
    input clk,
    input reset,
    input valid_in,
    input [DATA_WIDTH * N - 1:0] data_in,
    output valid_out,
    output reg [DATA_WIDTH * (N / DEC_FACTOR) - 1:0] data_out,
    output [DATA_WIDTH - 1:0] peak_value
);

    reg [DATA_WIDTH - 1:0] decimated_data [N / DEC_FACTOR - 1:0];
    integer index;
    logic max_detected = 0;

    // Input data registering
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            decimated_data = {1'b0, {DATA_WIDTH{1'b0}}};
            max_detected = 0;
        end else if (valid_in) begin
            decimated_data = data_in;
            max_detected = decimated_data[0];
        end
    end

    // Decimation process
    always @(posedge clk) begin
        for (index = 0; index < N / DEC_FACTOR; index++) begin
            decimated_data[index] = decimated_data[index * DEC_FACTOR];
        end
    end

    // Peak detection
    always @(posedge clk) begin
        for (index = 0; index < N / DEC_FACTOR; index++) begin
            if (decimated_data[index] > max_detected) begin
                max_detected = decimated_data[index];
            end
        end
    end

    // Output packing
    always @(posedge clk) begin
        data_out = {(DEC_FACTOR - 1)'b0, decimated_data[(N / DEC_FACTOR - 1):0]};
        if (max_detected != 0) begin
            peak_value = max_detected;
        end else begin
            peak_value = {1'b0, (DATA_WIDTH-1)'b0};
        end
        valid_out = valid_in;
    end

endmodule
