
module alu_seq (
    input i_clk,          // Clock signal
    input i_rst_b,        // Active-low asynchronous reset
    input [3:0] i_operand_a, // 4-bit input operand A
    input [3:0] i_operand_b, // 4-bit input operand B
    input [2:0] i_opcode,    // 3-bit operation code
    input [7:0] i_key_in,    // 8-bit security key input
    output reg [7:0] o_result // 8-bit operation result
);

    // Internal configurable security key
    reg [7:0] p_key = 8'hAA;

    // State to track whether the operation is allowed
    reg [2:0] op_state;

    // Always block for clocked logic
    always @(posedge i_clk) begin
        if (i_rst_b) begin
            o_result <= 8'b0;
            op_state <= 3'b000; // Disallow any operation
        end else begin
            // Check if the security key matches
            if (i_key_in == p_key) begin
                op_state <= i_opcode;
            end else begin
                op_state <= 3'b000; // Disallow any operation
            end
        end
    end

    // Sequential logic for operations
    always @(op_state) begin
        case (op_state)
            3'b000: o_result <= 8'b0; // Reset state
            3'b001: o_result <= i_operand_a - i_operand_b; // Subtraction
            3'b010: o_result <= i_operand_a * i_operand_b; // Multiplication
            3'b011: o_result <= i_operand_a & i_operand_b; // Bitwise AND
            3'b100: o_result <= i_operand_a | i_operand_b; // Bitwise OR
            3'b101: o_result <= ~i_operand_a; // Bitwise NOT
            3'b110: o_result <= i_operand_a ^ i_operand_b; // Bitwise XOR
            3'b111: o_result <= ~(i_operand_a ^ i_operand_b); // Bitwise XNOR
            default: o_result <= 8'b0; // Default case, no operation
        endcase
    end

endmodule

