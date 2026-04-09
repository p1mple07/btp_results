module alu_seq (
    input i_clk,          // Clock signal
    input i_rst_b,        // Active-low asynchronous reset
    input [3:0] i_operand_a, // 4-bit input operand A
    input [3:0] i_operand_b, // 4-bit input operand B
    input [2:0] i_opcode,    // 3-bit operation code
    input [7:0] i_key_in,    // 8-bit security key input
    output reg [7:0] o_result // 8-bit operation result
);

reg [7:0] p_key;           // Internal security key register
reg [7:0] p_op_result;     // Operation result register

always @(posedge i_clk or posedge i_rst_b) begin
    if (i_rst_b == 1'b0) begin
        p_key <= 8'hAA;         // Reset internal key to default value
        p_op_result <= 8'b0;   // Reset operation result to 0
    end else begin
        if (i_key_in!= p_key) begin
            p_op_result <= 8'b0;   // No operation if key does not match
        end else begin
            case (i_opcode)
                3'd0: p_op_result <= i_operand_a + i_operand_b;
                3'd1: p_op_result <= i_operand_a - i_operand_b;
                3'd2: p_op_result <= i_operand_a * i_operand_b;
                3'd3: p_op_result <= i_operand_a & i_operand_b;
                3'd4: p_op_result <= i_operand_a | i_operand_b;
                3'd5: p_op_result <= ~i_operand_a;
                3'd6: p_op_result <= i_operand_a ^ i_operand_b;
                3'd7: p_op_result <= ~(i_operand_a ^ i_operand_b);
                default: p_op_result <= 8'b0; // Default case
            endcase
        end
    end
end

assign o_result = p_op_result; // Assign operation result to output port

endmodule