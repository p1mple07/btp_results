module signedadder #(parameter DATA_WIDTH = 8)(
    input i_clk,
    input i_rst_n,
    input i_start,
    input i_enable,
    input i_mode,
    input i_clear,
    input [DATA_WIDTH-1:0] i_operand_a,
    input [DATA_WIDTH-1:0] i_operand_b,
    output reg [DATA_WIDTH-1:0] o_resultant_sum,
    output reg o_overflow,
    output reg o_ready,
    output reg [1:0] o_status
);

    // Add your code here

endmodule