module alu_seq (
    input i_clk,          // Clock signal
    input i_rst_b,        // Active-low asynchronous reset
    input [3:0] i_operand_a, // 4-bit input operand A
    input [3:0] i_operand_b, // 4-bit input operand B
    input [2:0] i_opcode,    // 3-bit operation code
    input [7:0] i_key_in,    // 8-bit security key input
    output reg [7:0] o_result // 8-bit operation result
);

    // Check if reset is asserted
    if (i_rst_b == 0) begin
        o_result = 0;
        return;
    end

    // Check if key matches internal key (0xAA)
    if (i_key_in != 8'b00001010) begin
        o_result = 0;
        return;
    end

    // Perform operation based on opcode
    case (i_opcode)
        0: o_result = i_operand_a + i_operand_b;
        1: o_result = i_operand_a - i_operand_b;
        2: o_result = i_operand_a * i_operand_b;
        3: o_result = i_operand_a & i_operand_b;
        4: o_result = i_operand_a | i_operand_b;
        5: o_result = ~i_operand_a;
        6: o_result = i_operand_a ^ i_operand_b;
        7: o_result = ~ (i_operand_a ^ i_operand_b);
    endcase

endmodule