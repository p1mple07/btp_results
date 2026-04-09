module alu_seq (
    input i_clk,
    input i_rst_b,
    input [3:0] i_operand_a,
    input [3:0] i_operand_b,
    input [2:0] i_opcode,
    input [7:0] i_key_in,
    output reg [7:0] o_result
);

parameter p_key = 8'hAA;

always @(i_clk or i_rst_b) begin
    if (i_rst_b)
        o_result <= 8'b0;
    else
        if (i_key_in == p_key) begin
            case (i_opcode)
                4'b000: o_result = i_operand_a + i_operand_b;
                4'b001: o_result = i_operand_a - i_operand_b;
                4'b010: o_result = i_operand_a * i_operand_b;
                4'b011: o_result = i_operand_a & i_operand_b;
                4'b100: o_result = i_operand_a | i_operand_b;
                4'b101: ~i_operand_a;
                4'b110: i_operand_a ^ i_operand_b;
                4'b111: ~(i_operand_a ^ i_operand_b);
            endcase
        end else
            o_result <= 8'b0;
end

endmodule
