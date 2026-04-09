
module alu_seq (
    input i_clk,          // Clock signal
    input i_rst_b,        // Active-low asynchronous reset
    input [3:0] i_operand_a, // 4-bit input operand A
    input [3:0] i_operand_b, // 4-bit input operand B
    input [2:0] i_opcode,    // 3-bit operation code
    input [7:0] i_key_in,    // 8-bit security key input
    output reg [7:0] o_result // 8-bit operation result
);

    // Internal configuration
    reg [7:0] p_key = 8'hAA;

    // State register
    reg [7:0] s_result = 8'h0000;

    // Reset logic
    always @(posedge i_clk or negedge i_rst_b) begin
        if (!i_rst_b) begin
            s_result <= 8'h0000;
        end else begin
            if (i_key_in == p_key) begin
                case(i_opcode)
                    3'b000: s_result <= i_operand_a + i_operand_b;
                    3'b001: s_result <= i_operand_a - i_operand_b;
                    3'b010: s_result <= i_operand_a * i_operand_b;
                    3'b011: s_result <= i_operand_a & i_operand_b;
                    3'b100: s_result <= i_operand_a | i_operand_b;
                    3'b101: s_result <= ~i_operand_a;
                    3'b110: s_result <= i_operand_a ^ i_operand_b;
                    3'b111: s_result <= ~(i_operand_a ^ i_operand_b);
                    default: s_result <= 8'h0000;
                endcase
            end
        end
    end

    // Output logic
    assign o_result = s_result;

endmodule

