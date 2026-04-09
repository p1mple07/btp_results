module advanced_decimator_with_adaptive_peak_detection #(
    parameter N = 8,
    parameter DATA_WIDTH = 16,
    parameter DEC_FACTOR = 4
) (
    input clk,
    input reset,
    input valid_in,
    input [DATA_WIDTH * N - 1:0] data_in,
    output reg valid_out,
    output [DATA_WIDTH * (N / DEC_FACTOR) - 1:0] data_out,
    output [DATA_WIDTH - 1:0] peak_value
);

    reg [DATA_WIDTH - 1:0] decimated_data [N / DEC_FACTOR - 1:0];
    reg [DATA_WIDTH - 1:0] peak_reg;
    integer i;

    // Input data registering
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            decimated_data <= {DATA_WIDTH{1'b0}};
            peak_reg <= DATA_WIDTH'h0;
            valid_out <= 0;
        end else if (valid_in) begin
            for (i = 0; i < N / DEC_FACTOR; i = i + 1) begin
                decimated_data[i] <= data_in[(i * DEC_FACTOR +: DATA_WIDTH * DEC_FACTOR)];
            end
            valid_out <= 1;
        end else begin
            valid_out <= 0;
        end
    end

    // Peak detection
    always @(posedge clk) begin
        if (valid_out) begin
            peak_reg <= peak_reg;
            for (i = 0; i < N / DEC_FACTOR; i = i + 1) begin
                if (decimated_data[i] > peak_reg) begin
                    peak_reg <= decimated_data[i];
                end
            end
        end
    end

    // Output packing
    always @(posedge clk) begin
        if (valid_out) begin
            data_out <= decimated_data;
            peak_value <= peak_reg;
        end
    end

endmodule
