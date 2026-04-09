module advanced_decimator_with_adaptive_peak_detection #(
    parameter int N = 8,
    parameter int DATA_WIDTH = 16,
    parameter int DEC_FACTOR = 4
)(
    input wire clk,
    input wire reset,
    input wire valid_in,
    input wire [DATA_WIDTH*N-1:0] data_in,
    output reg valid_out,
    output reg [DATA_WIDTH*(N/DEC_FACTOR)-1:0] data_out,
    output reg [DATA_WIDTH-1:0] peak_value
);

reg [DATA_WIDTH*(N-1):0] data_reg;
reg [DATA_WIDTH*(N/DEC_FACTOR)-1:0] decimated_data[N/DEC_FACTOR-1:0];
reg [N/DEC_FACTOR-1:0] selected_sample;
reg [DATA_WIDTH-1:0] max_value;
reg [N/DEC_FACTOR-1:0] counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        data_reg <= 0;
        selected_sample <= 0;
        max_value <= 0;
        counter <= 0;
    end else if (valid_in) begin
        data_reg <= data_in;
        counter <= 0;
    end
end

assign valid_out = valid_in;

always @(*) begin
    for (int i=0; i<N/DEC_FACTOR-1; i++) begin
        decimated_data[i] = data_reg[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH];
        selected_sample[i] = decimated_data[i][(counter[i]*DEC_FACTOR)+DATA_WIDTH-1 : counter[i]*DEC_FACTOR];
    end
    
    decimated_data[N/DEC_FACTOR-1] = data_reg[(N-1)*DATA_WIDTH-1 : (N/DEC_FACTOR-1)*DATA_WIDTH];
    selected_sample[N/DEC_FACTOR-1] = decimated_data[N/DEC_FACTOR-1][(counter[N/DEC_FACTOR-1]*DEC_FACTOR)+DATA_WIDTH-1 : counter[N/DEC_FACTOR-1]*DEC_FACTOR];
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        max_value <= 0;
        counter <= 0;
    end else if (valid_in) begin
        max_value <= selected_sample[0];
        for (int i=0; i<N/DEC_FACTOR-1; i++) begin
            if (selected_sample[i] > max_value) begin
                max_value <= selected_sample[i];
            end
        end
        
        counter <= counter + 1;
    end
end

assign data_out = selected_sample[0];
assign peak_value = max_value;

endmodule