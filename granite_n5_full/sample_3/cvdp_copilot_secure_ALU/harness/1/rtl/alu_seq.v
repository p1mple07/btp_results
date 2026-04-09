module alu_seq (
    input i_clk,          // Clock signal
    input i_rst_b,        // Active-low asynchronous reset
    input [3:0] i_operand_a, // 4-bit input operand A
    input [3:0] i_operand_b, // 4-bit input operand B
    input [2:0] i_opcode,    // 3-bit operation code
    input [7:0] i_key_in,    // 8-bit security key input
    output reg [7:0] o_result // 8-bit operation result
);

    reg [7:0] p_key;      // Internal security key
    wire [7:0] w_result;   // Internal operation result

    assign p_key = 8'dAA; // Default to 0xAA

    always @(posedge i_clk or posedge i_rst_b) begin
        if (i_rst_b == 1'b0) begin
            o_result <= 8'b0;
        end else begin
            if (i_key_in == p_key) begin
                case (i_opcode)
                    3'b000: o_result <= i_operand_a + i_operand_b;
                    3'b001: o_result <= i_operand_a - i_operand_b;
                    3'b010: o_result <= i_operand_a * i_operand_b;
                    3'b011: o_result <= i_operand_a & i_operand_b;
                    3'b100: o_result <= i_operand_a | i_operand_b;
                    3'b101: o_result <= ~i_operand_a;
                    3'b110: o_result <= i_operand_a ^ i_operand_b;
                    3'b111: o_result <= ~(i_operand_a ^ i_operand_b);
                    default: o_result <= 8'b0;
                endcase
            end else begin
                o_result <= 8'b0;
            end
        end
    end

endmodule