module pipelined_modified_booth_multiplier(
    input clk,
    input valid,
    input [15:0] x,
    input [15:0] y
    output [15:0] result,
    output int valid
);

always @ (posedge clk) begin
    if (valid) begin
        result = x * y
    end
endmodule