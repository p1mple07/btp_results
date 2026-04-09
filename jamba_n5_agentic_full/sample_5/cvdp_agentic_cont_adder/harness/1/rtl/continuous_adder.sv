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

reg [DATA_WIDTH-1:0] sum_reg;
reg [31:0] sum_expected;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_reg <= 0;
        sum_valid <= 0;
    end else begin
        if (accumulate_enable) begin
            if (valid_in) begin
                sum_reg <= sum_reg + data_in;
            end
        end else if (flush) begin
            sum_reg <= 0;
        end
    end
end

always @(posedge clk) begin
    if (REGISTER_OUTPUT) begin
        sum_out <= sum_reg;
        sum_valid <= (sum_reg == sum_expected);
    end else begin
        sum_out <= sum_reg;
        sum_valid <= (sum_reg == sum_expected);
    end
end

always @(posedge clk) begin
    if (flush) begin
        sum_reg <= 0;
    end
end

endmodule
