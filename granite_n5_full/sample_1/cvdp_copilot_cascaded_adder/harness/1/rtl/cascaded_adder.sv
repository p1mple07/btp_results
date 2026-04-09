module cascaded_adder #(
    parameter IN_DATA_WIDTH = 16,
    parameter IN_DATA_NS    = 4
) (
    input logic clk,
    input logic rst_n,
    input logic i_valid,
    input logic signed [IN_DATA_WIDTH - 1 : 0] i_data [IN_DATA_NS - 1 : 0],
    output logic o_valid,
    output logic signed [IN_DATA_WIDTH - 1 : 0] o_data
);

logic signed [IN_DATA_WIDTH - 1 : 0] reg_data [IN_DATA_NS];
logic signed [IN_DATA_WIDTH - 1 : 0] sum;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        reg_data <= '0;
    end else if (i_valid) begin
        reg_data <= i_data;
    end
end

assign sum = ({1'b0, reg_data} & {IN_DATA_WIDTH{1'b0}}, {IN_DATA_WIDTH{1'b0}}))[IN_DATA_WIDTH +: IN_DATA_WIDTH];

always_ff @(posedge clk) begin
    if (!rst_n) begin
        o_data <= '0;
    end else begin
        o_data <= sum;
    end
end

assign o_valid = i_valid;

endmodule