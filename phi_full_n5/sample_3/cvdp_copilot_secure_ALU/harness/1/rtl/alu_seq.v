
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

    // State register to hold the result
    reg [7:0] temp_result;

    // Comparator for the key
    always @ (i_key_in) begin
        if (i_key_in == p_key) begin
            // Key matches, perform operation
            if (i_opcode == 3'b000) begin
                temp_result = i_operand_a + i_operand_b;
            end else if (i_opcode == 3'b001) begin
                temp_result = i_operand_a - i_operand_b;
            end else if (i_opcode == 3'b010) begin
                temp_result = i_operand_a * i_operand_b;
            end else if (i_opcode == 3'b011) begin
                temp_result = i_operand_a & i_operand_b;
            end else if (i_opcode == 3'b100) begin
                temp_result = i_operand_a | i_operand_b;
            end else if (i_opcode == 3'b101) begin
                temp_result = ~i_operand_a;
            end else if (i_opcode == 3'b110) begin
                temp_result = i_operand_a ^ i_operand_b;
            end else if (i_opcode == 3'b111) begin
                temp_result = ~(i_operand_a ^ i_operand_b);
            end
        end else begin
            // Key does not match, result is 0
            temp_result = 8'b0;
        end
    end

    // Asynchronous reset
    always @ (posedge i_clk or negedge i_rst_b) begin
        if (!i_rst_b) begin
            o_result <= 8'b0;
        end else begin
            o_result <= temp_result;
        end
    end

endmodule

