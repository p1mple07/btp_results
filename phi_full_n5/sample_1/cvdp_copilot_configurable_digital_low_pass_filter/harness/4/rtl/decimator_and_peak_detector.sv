module advanced_decimator_with_adaptive_peak_detection #(parameter DATA_WIDTH = 16, DEC_FACTOR = 4)
(
    input clk,
    input reset,
    input valid_in,
    input [DATA_WIDTH * DEC_FACTOR - 1:0] data_in,
    output reg valid_out,
    output [DATA_WIDTH - 1:0] data_out,
    output [DATA_WIDTH - 1:0] peak_value
);

    reg [DATA_WIDTH - 1:0] decimated_data [DEC_FACTOR - 1:0];
    reg [DATA_WIDTH - 1:0] peak_temp;

    // Input Data Registering
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            decimated_data <= {DATA_WIDTH{1'b0}};
            peak_temp <= data_in[0];
            valid_out <= 1;
        end else if (valid_in) begin
            decimated_data <= {data_in[DATA_WIDTH*(DEC_FACTOR-1)+:DATA_WIDTH]};
            peak_temp <= decimated_data[0];
            valid_out <= 1;
        end else begin
            peak_temp <= 1'b0;
            valid_out <= 0;
        end
    end

    // Decimation
    always @(posedge clk) begin
        if (valid_out) begin
            decimated_data[0] <= data_in[DATA_WIDTH*(DEC_FACTOR-1)+:DATA_WIDTH];
            for (int i = 1; i < DEC_FACTOR; i++) begin
                decimated_data[i] <= data_in[(i-1)*DATA_WIDTH +: DATA_WIDTH];
            end
        end
    end

    // Peak Detection
    always @(posedge clk) begin
        if (valid_out) begin
            peak_temp = decimated_data[0];
            for (int i = 1; i < DEC_FACTOR; i++) begin
                if (decimated_data[i] > peak_temp) begin
                    peak_temp = decimated_data[i];
                end
            end
        end
    end

    // Output Packing
    always @(posedge clk) begin
        if (valid_out) begin
            data_out = decimated_data[DEC_FACTOR - 1];
            peak_value = peak_temp;
        end
    end

endmodule
