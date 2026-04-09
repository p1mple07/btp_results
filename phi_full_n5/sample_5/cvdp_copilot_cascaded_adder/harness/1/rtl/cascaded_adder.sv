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

    reg [IN_DATA_WIDTH - 1:0] sum;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            sum <= 0;
            o_valid <= 0;
        end else if (i_valid) begin
            if (sum < (1 << (IN_DATA_WIDTH * IN_DATA_NS - 1))) begin
                sum <= sum + i_data;
                o_valid <= 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (o_valid) begin
            o_data <= sum;
        end
    end

endmodule
