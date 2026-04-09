module continuous_adder #(
    parameter integer DATA_WIDTH       = 32,
    parameter integer ENABLE_THRESHOLD = 0,
    parameter integer THRESHOLD        = 16,
    parameter integer REGISTER_OUTPUT  = 0
) (
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire accumulate_enable,
    input  wire flush,
    output reg  [DATA_WIDTH-1:0] sum_out,
    output reg  sum_valid
);

reg [DATA_WIDTH-1:0] sum_reg;
reg [DATA_WIDTH-1:0] sum;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_reg <= 0;
        sum <= 0;
        sum_valid <= 0;
    end else begin
        if (accumulate_enable) begin
            sum_reg <= sum_reg + data_in;
        end
        if (flush) begin
            sum_reg <= 0;
            sum <= 0;
        end
    end
end

always @(posedge clk) begin
    if (REGISTER_OUTPUT) begin
        sum_out <= sum;
        sum_valid <= sum_valid;
    end else
        sum_out <= sum;
        sum_valid <= sum_valid;
    end

    if (ENABLE_THRESHOLD) begin
        if (sum_reg >= THRESHOLD) begin
            sum_valid <= 1;
        end else
            sum_valid <= 0;
    end
end

endmodule
