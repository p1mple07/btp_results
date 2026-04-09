module alu_seq (
    input i_clk,          // Clock signal
    input i_rst_b,        // Active-low asynchronous reset
    input [3:0] i_operand_a, // 4-bit input operand A
    input [3:0] i_operand_b, // 4-bit input operand B
    input [2:0] i_opcode,    // 3-bit operation code
    input [7:0] i_key_in,    // 8-bit security key input
    output reg [7:0] o_result // 8-bit operation result
);

reg [7:0] p_key = 8'hAA; // Internal configuration

always @(posedge i_clk or posedge i_rst_b) begin
    if (i_rst_b == 1'b0) begin
        o_result <= 8'b0; // Reset output
    end else if (i_key_in == p_key) begin
        case (i_opcode)
            3'b000: o_result <= i_operand_a + i_operand_b; // Addition
            3'b001: o_result <= i_operand_a - i_operand_b; // Subtraction
            3'b010: o_result <= i_operand_a * i_operand_b; // Multiplication
            3'b011: o_result <= i_operand_a & i_operand_b; // Bitwise AND
            3'b100: o_result <= i_operand_a | i_operand_b; // Bitwise OR
            3'b101: o_result <= ~i_operand_a;           // Bitwise NOT
            3'b110: o_result <= i_operand_a ^ i_operand_b; // Bitwise XOR
            3'b111: o_result <= ~(i_operand_a ^ i_operand_b); // Bitwise XNOR
            default: o_result <= 8'b0; // Invalid operation
        endcase
    } else begin
        o_result <= 8'b0; // Operation not allowed
    end
end

endmodule