module signedadder #(parameter DATA_WIDTH = 8) (
    input i_clk,
    input i_rst_n,
    input i_start,
    input i_enable,
    input i_mode,
    input i_clear,
    input [DATA_WIDTH-1:0] i_operand_a,
    input [DATA_WIDTH-1:0] i_operand_b,
    output reg [DATA_WIDTH-1:0] o_resultant_sum,
    output reg o_overflow,
    output reg o_ready,
    output reg [1:0] o_status
);

reg [DATA_WIDTH-1:0] result;
reg overflow_flag;
reg [1:0] state;
reg next_state;

always @(posedge i_clk or posedge i_rst_n) begin
    if (!i_rst_n) begin
        state <= 2'b0;
        result <= 0;
        overflow_flag <= 1'b0;
        o_ready <= 1'b0;
        o_status <= 2'b00;
        return;
    end

    case (state)
        2'b00: // IDLE
            if (i_start) begin
                state <= 2'b01;
            end
        endcase

        2'b01: // LOAD
            if (i_enable) begin
                // load operands
                result <= i_operand_a;
                overflow_flag <= 0;
            end
            next_state = 2'b00;
        endcase

        2'b10: // COMPUTE
            if (i_mode == 1'b0) begin
                result = i_operand_a + i_operand_b;
            else begin
                result = i_operand_a - (~i_operand_b);
            end
            overflow_flag = (i_operand_a ^ i_operand_b) && (result[DATA_WIDTH-1] == 1'b1);
            next_state = 2'b11;
        endcase

        2'b11: // OUTPUT
            o_resultant_sum <= result;
            o_overflow <= overflow_flag;
            o_ready <= 1'b1;
            o_status = 2'b10;
            state <= 2'b0;
    endcase
endalways

always @(*) begin
    if (i_clear) begin
        state <= 2'b0;
        overflow_flag <= 1'b0;
        result <= 0;
        o_ready <= 1'b0;
        o_status <= 2'b00;
    end
end

always @(i_start or i_enable) begin
    if (i_rst_n) begin
        state <= 2'b0;
        overflow_flag <= 1'b0;
        result <= 0;
        o_ready <= 1'b0;
        o_status <= 2'b00;
        return;
    end
    if (i_clear) begin
        state <= 2'b0;
        overflow_flag <= 1'b0;
        result <= 0;
        o_ready <= 1'b0;
        o_status <= 2'b00;
        return;
    end
end

endmodule
