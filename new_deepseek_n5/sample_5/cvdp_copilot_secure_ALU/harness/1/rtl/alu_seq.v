module alu_seq (
    input i_clk,          // Clock signal
    input i_rst_b,        // Active-low asynchronous reset
    input [3:0] i_operand_a, // 4-bit input operand A
    input [3:0] i_operand_b, // 4-bit input operand B
    input [2:0] i_opcode,    // 3-bit operation code
    input [7:0] i_key_in,    // 8-bit security key input
    output reg [7:0] o_result // 8-bit operation result
);

    reg [7:0] p_key = 0xAA; // Internal configurable security key

    always @ (i_rst_b, i_key_in, i_opcode) begin
        if (i_key_in != p_key) begin
            o_result = 8'b0;
        else begin
            case (i_opcode)
                000: o_result = i_operand_a + i_operand_b;
                001: o_result = i_operand_a - i_operand_b;
                010: o_result = i_operand_a * i_operand_b;
                011: o_result = i_operand_a & i_operand_b;
                100: o_result = i_operand_a | i_operand_b;
                101: o_result = ~i_operand_a;
                110: o_result = i_operand_a ^ i_operand_b;
                111: o_result = ~ (i_operand_a ^ i_operand_b);
                default: o_result = 8'b0;
            endcase
        end
    end

endmodule