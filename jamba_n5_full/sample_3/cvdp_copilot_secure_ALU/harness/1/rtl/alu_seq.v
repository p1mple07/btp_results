module alu_seq (
    input i_clk,
    input i_rst_b,
    input [3:0] i_operand_a,
    input [3:0] i_operand_b,
    input [2:0] i_opcode,
    input [7:0] i_key_in,
    output reg [7:0] o_result
);

reg [8:0] p_key = 0xAA;

initial begin
    o_result = 8'b0;
end

always @(i_clk or i_rst_b) begin
    if (i_rst_b)
        o_result <= 8'b0;
    else
    begin
        if (i_key_in == p_key)
        begin
            case (i_opcode)
                2'b00: o_result = i_operand_a + i_operand_b;
                2'b01: o_result = i_operand_a - i_operand_b;
                2'b10: o_result = i_operand_a * i_operand_b;
                2'b11: o_result = i_operand_a & i_operand_b;
                100: o_result = ~i_operand_a;
                101: o_result = ~i_operand_a;
                110: o_result = i_operand_a ^ i_operand_b;
                111: o_result = ~(i_operand_a ^ i_operand_b);
            endcase
        end
        else
        begin
            o_result = 8'b0;
        end
    end
end

endmodule
