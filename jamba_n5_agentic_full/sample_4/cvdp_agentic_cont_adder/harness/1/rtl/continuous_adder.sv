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

localvar reg [DATA_WIDTH-1:0] sum_reg;
localvar logic sum_valid_flag;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_reg <= 0;
        sum_valid_flag <= 0;
    end else begin
        if (accumulate_enable) begin
            sum_reg <= sum_reg + data_in;
        end
        if (flush) begin
            sum_reg <= 0;
        end
    end
end

always @(posedge clk) begin
    sum_out = sum_reg;
    sum_valid_flag = sum_reg >= THRESHOLD;
    sum_valid = sum_valid_flag;
end

endmodule
