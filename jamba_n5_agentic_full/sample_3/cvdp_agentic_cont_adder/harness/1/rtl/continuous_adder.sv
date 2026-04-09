// rtl/continuous_adder.sv
module continuous_adder #(
    parameter integer DATA_WIDTH       = 32,
    parameter integer ENABLE_THRESHOLD = 0,
    parameter integer THRESHOLD        = 16,
    parameter integer REGISTER_OUTPUT  = 0
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire accumulate_enable,
    input  wire flush,
    output reg  [DATA_WIDTH-1:0] sum_out,
    output reg  sum_valid
);

localparam integer MAX_VAL = 1 << DATA_WIDTH; // maximum possible value

reg [DATA_WIDTH-1:0] sum_reg;
reg [DATA_WIDTH-1:0] temp;
reg is_threshold_met;
reg is_register_output_enabled;

always @(posedge clk) begin
    if (rst_n) begin
        sum_reg <= 0;
        sum_valid <= 0;
        is_threshold_met <= 0;
        is_register_output_enabled <= 0;
    end else begin
        if (accumulate_enable) begin
            if (valid_in) begin
                sum_reg <= sum_reg + data_in;
            end else begin
                sum_reg <= sum_reg; // no change
            end
        end else begin
            sum_reg <= sum_reg;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_reg <= 0;
        sum_valid <= 0;
        is_threshold_met <= 0;
        is_register_output_enabled <= 0;
    end else begin
        if (flush) begin
            sum_reg <= 0;
            sum_valid <= 0;
        end else if (ENABLE_THRESHOLD) begin
            is_threshold_met <= sum_reg >= THRESHOLD;
        end
    end
end

always @(posedge clk) begin
    if (REGISTER_OUTPUT) begin
        sum_out <= sum_reg;
        sum_valid <= is_threshold_met;
    end else begin
        sum_out <= sum_reg;
        sum_valid <= is_threshold_met;
    end
end

endmodule
