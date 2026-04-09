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

    reg [IN_DATA_WIDTH - 1:0] temp_sum;
    reg [IN_DATA_WIDTH - 1:0] stage_sum;

    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            temp_sum <= 0;
            stage_sum <= 0;
            o_valid <= 0;
        end else if (i_valid) begin
            temp_sum <= i_data;
            stage_sum <= temp_sum;
            o_valid <= 1;
        end else begin
            o_valid <= 0;
        end
    end

    always_comb begin
        if (o_valid) begin
            o_data <= {stage_sum, temp_sum};
        end
    end

endmodule
