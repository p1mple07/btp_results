module advanced_decimator_with_adaptive_peak_detection #(parameter N = 8, DATA_WIDTH = 16, DEC_FACTOR = 4)
(
    input clk,
    input reset,
    input valid_in,
    input [DATA_WIDTH * N - 1:0] data_in,
    output reg valid_out,
    output [DATA_WIDTH * (N / DEC_FACTOR) - 1:0] data_out,
    output [DATA_WIDTH - 1:0] peak_value
);

    reg [DATA_WIDTH - 1:0] decimated_data [N / DEC_FACTOR - 1:0];
    integer i;

    // Input Data Registering
    always @(posedge clk) begin
        if (reset) begin
            decimated_data <= {DATA_WIDTH{1'b0}};
        end else begin
            decimated_data <= {data_in[i * DATA_WIDTH +: DATA_WIDTH] for i in 0:N - 1};
        end
    end

    // Decimation
    always @(valid_in or decimated_data) begin
        if (valid_in) begin
            for (i = 0; i < N / DEC_FACTOR; i++) begin
                decimated_data[i] = decimated_data[i] ? decimated_data[i] : data_in[(i * DEC_FACTOR) * DATA_WIDTH +: DATA_WIDTH];
            end
        end
        valid_out = valid_in;
    end

    // Peak Detection
    always @(valid_in or decimated_data) begin
        if (valid_in) begin
            peak_value = decimated_data[0];
            for (i = 1; i < N / DEC_FACTOR; i++) begin
                if (decimated_data[i] > peak_value) begin
                    peak_value = decimated_data[i];
                end
            end
        end
    end

    // Output Packing
    assign data_out = {decimated_data[i] for i in 0:N / DEC_FACTOR - 1};

endmodule
