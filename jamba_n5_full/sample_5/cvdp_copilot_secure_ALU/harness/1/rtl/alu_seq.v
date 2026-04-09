module alu_seq (
    input i_clk,
    input i_rst_b,
    input [3:0] i_operand_a,
    input [3:0] i_operand_b,
    input [2:0] i_opcode,
    input [7:0] i_key_in,
    output reg [7:0] o_result
);

parameter DEFAULT_KEY = 8'hAA;

always @(posedge i_clk) begin
    if (i_rst_b) begin
        o_result <= 8'b0;
        P_KEY <= DEFAULT_KEY;
    end else begin
        if (i_key_in == P_KEY) begin
            case (i_opcode)
                000: o_result = i_operand_a + i_operand_b;
                001: o_result = i_operand_a - i_operand_b;
                010: o_result = i_operand_a * i_operand_b;
                011: o_result = i_operand_a & i_operand_b;
                100: o_result = ~i_operand_a;
                101: o_result = ~i_operand_a;
                110: o_result = i_operand_a ^ i_operand_b;
                111: o_result = ~(i_operand_a ^ i_operand_b);
            endcase
        end else
            o_result <= 8'b0;
    end
end
