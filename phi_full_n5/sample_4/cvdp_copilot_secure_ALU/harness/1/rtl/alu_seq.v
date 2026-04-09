
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

    // State variable to hold the result when reset or key does not match
    reg [7:0] st_result = 8'h00;

    always @(posedge i_clk or posedge i_rst_b) begin
        if (i_rst_b) begin
            st_result <= 8'h00;
        end else if (i_key_in != p_key) begin
            st_result <= 8'h00;
        end else begin
            case (i_opcode)
                3'b000: st_result <= i_operand_a + i_operand_b;
                3'b001: st_result <= i_operand_a - i_operand_b;
                3'b010: st_result <= i_operand_a * i_operand_b;
                3'b011: st_result <= i_operand_a & i_operand_b;
                3'b100: st_result <= i_operand_a | i_operand_b;
                3'b101: st_result <= ~i_operand_a;
                3'b110: st_result <= i_operand_a ^ i_operand_b;
                3'b111: st_result <= ~(i_operand_a ^ i_operand_b);
                default: st_result <= 8'h00;
            endcase
        end
    end

    assign o_result = st_result;

endmodule

