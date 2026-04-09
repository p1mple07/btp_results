module cascaded_adder #(
    parameter IN_DATA_WIDTH = 16,
    parameter IN_DATA_NS = 4
) (
    input clk,
    input rst_n,
    input i_valid,
    input [IN_DATA_WIDTH * IN_DATA_NS - 1:0] i_data,
    output reg o_valid,
    output [IN_DATA_WIDTH + $clog2(IN_DATA_NS) - 1:0] o_data
);

    reg [IN_DATA_WIDTH - 1:0] accumulator;
    integer i;

    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            accumulator <= 0;
            o_valid <= 0;
        end else if (i_valid) begin
            accumulator <= i_data;
            o_valid <= 1;
        end else begin
            o_valid <= 0;
        end
    end

    always_ff @(posedge clk) begin
        if (o_valid) begin
            for (i = 0; i < IN_DATA_NS; i = i + 1) begin
                accumulator <= accumulator + {accumulator[IN_DATA_WIDTH - 1], i_data[(i * IN_DATA_WIDTH) + IN_DATA_WIDTH - 1:IN_DATA_WIDTH * i]};
            end
            o_data <= accumulator;
        end
    end

endmodule
