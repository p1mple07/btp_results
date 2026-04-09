module advanced_decimator_with_adaptive_peak_detection #(
    parameter N = 8,
    parameter DATA_WIDTH = 16,
    parameter DEC_FACTOR = 4
)(
    input wire clk,
    input wire reset,
    input wire valid_in,
    input data_in[$bits[DATA_WIDTH*N-1:0]],
    output reg valid_out,
    output reg [DATA_WIDTH*N-1:0] data_out,
    output reg [DATA_WIDTH-1:0] peak_value
);

    localparam DEC_FACTOR = 4;

    reg [DATA_WIDTH*N-1:0] data_packed;
    reg [DATA_WIDTH-1:0] decimated_data[0:(N/DEC_FACTOR)-1];
    reg [DATA_WIDTH-1:0] current_peak;

    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            data_packed <= 0;
            decimated_data[0:(N/DEC_FACTOR)-1] <= 0;
            current_peak <= 0;
        end else begin
            for (int i = 0; i < N; i++) begin
                int idx = i * DEC_FACTOR;
                decimated_data[i] <= data_in[idx];
            end
        end
    end

    assign data_packed = {};
    for (int i = 0; i < (N/DEC_FACTOR); i++) begin
        data_packed = data_packed + decimated_data[i];
    end

    assign peak_value = {1, decimated_data[0]};
    for (int i = 1; i < (N/DEC_FACTOR); i++) begin
        current_peak = {current_peak[1], decimated_data[i] > current_peak ? decimated_data[i] : current_peak};
    }

    assign data_out = {};
    for (int i = 0; i < (N/DEC_FACTOR); i++) begin
        data_out = data_out + decimated_data[i];
    end

    assign valid_out = valid_in;

endmodule
