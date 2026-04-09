
module alu_seq (
    input i_clk,          // Clock signal
    input i_rst_b,        // Active-low asynchronous reset
    input [3:0] i_operand_a, // 4-bit input operand A
    input [3:0] i_operand_b, // 4-bit input operand B
    input [2:0] i_opcode,    // 3-bit operation code
    input [7:0] i_key_in,    // 8-bit security key input
    output reg [7:0] o_result // 8-bit operation result
);

    // Internal security key
    reg [7:0] p_key = 8'hAA;

    // State variable for the operation
    reg [7:0] temp_result;

    // Always block for clocked operations
    always @(posedge i_clk) begin
        if (i_rst_b) begin
            o_result <= 8'b0;
            temp_result <= 8'b0;
        end else begin
            if (i_key_in == p_key) begin
                case (i_opcode)
                    3'b000: temp_result <= i_operand_a + i_operand_b;
                    3'b001: temp_result <= i_operand_a - i_operand_b;
                    3'b010: temp_result <= i_operand_a * i_operand_b;
                    3'b011: temp_result <= i_operand_a & i_operand_b;
                    3'b100: temp_result <= i_operand_a | i_operand_b;
                    3'b101: temp_result <= ~i_operand_a;
                    3'b110: temp_result <= i_operand_a ^ i_operand_b;
                    3'b111: temp_result <= ~(i_operand_a ^ i_operand_b);
                    default: temp_result <= 8'b0;
                endcase
                o_result <= temp_result;
            end else begin
                o_result <= 8'b0;
            end
        end
    end

endmodule

