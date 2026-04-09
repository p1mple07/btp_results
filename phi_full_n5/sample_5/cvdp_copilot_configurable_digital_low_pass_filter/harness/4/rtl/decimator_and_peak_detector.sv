module advanced_decimator_with_adaptive_peak_detection #(
    parameter N = 8,
    parameter DATA_WIDTH = 16,
    parameter DEC_FACTOR = 4
) (
    input clk,
    input reset,
    input valid_in,
    input [DATA_WIDTH * N - 1:0] data_in,
    output valid_out,
    output [DATA_WIDTH * (N / DEC_FACTOR) - 1:0] data_out,
    output [DATA_WIDTH - 1:0] peak_value
);

    // Internal registers
    reg [DATA_WIDTH * N - 1:0] data_reg;
    reg [DATA_WIDTH * (N / DEC_FACTOR) - 1:0] decimated_data;
    reg [DATA_WIDTH - 1:0] peak_value_reg;

    // Input data registering
    always @(posedge clk) begin
        if (reset) begin
            data_reg <= 0;
            peak_value_reg <= 0;
        end else begin
            data_reg <= data_in;
        end
    end

    // Input unpacking
    // No explicit unpacking logic required as data_in is already unpacked

    // Decimation process
    always @(posedge clk) begin
        if (reset) begin
            decimated_data <= 0;
        end else begin
            decimated_data <= {[DATA_WIDTH * (N / DEC_FACTOR) - 1:0](data_reg >> (DATA_WIDTH * (N / DEC_FACTOR) - DATA_WIDTH * (N % DEC_FACTOR)) & (DEC_FACTOR - 1));
        end
    end

    // Peak detection
    always @(posedge clk) begin
        if (reset) begin
            peak_value_reg <= data_reg[DATA_WIDTH - 1];
        end else begin
            peak_value_reg <= peak_value_reg;
            for (int i = 0; i < (N / DEC_FACTOR); i++) begin
                if (decimated_data[i * DATA_WIDTH + DATA_WIDTH - 1] > peak_value_reg) begin
                    peak_value_reg <= decimated_data[i * DATA_WIDTH + DATA_WIDTH - 1];
                end
            end
        end
    end

    // Output packing
    // No explicit packing logic required as decimated_data is already packed

    // Validation control
    always @(posedge clk) begin
        valid_out <= valid_in;
    end

endmodule
