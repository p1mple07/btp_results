module signedadder #(
    parameter DATA_WIDTH = 8
)(
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

reg [3:0] state;
reg [DATA_WIDTH-1:0] a, b;
reg [DATA_WIDTH-1:0] sum;
reg overflow;
reg ready;

always @(posedge i_clk) begin
    if (~i_rst_n) begin
        state <= 0;
        a <= 0; b <= 0;
        o_resultant_sum <= 0;
        o_overflow <= 0;
        o_ready <= 0;
        o_status = {1'b0, 1'b0};
        return;
    end

    case (state)
        0: begin // IDLE
            if (i_start && i_enable && i_mode == 0) begin
                state <= 1;
            end
        end
        1: begin // LOAD
            if (i_start && i_enable && i_mode == 1) begin
                state <= 2;
            end
        end
        2: begin // COMPUTE
            if (i_start && i_enable && i_mode == 0) begin
                sum = a + b;
            end else if (i_start && i_enable && i_mode == 1) begin
                sum = a - b;
            end
            // Overflow detection
            overflow = (a[DATA_WIDTH-1] != b[DATA_WIDTH-1]) ? ~a[DATA_WIDTH-1] : 0;
            // Actually, for overflow in 2's complement, we need to check if the sign bits differ and the magnitude is not equal.
            // Simplified: if a and b have different signs, overflow might happen.
            // But we can check the sign bits:
            overflow = (a[DATA_WIDTH-1] != b[DATA_WIDTH-1]) ? 1'b1 : 0;
            ready = 1;
        end
        3: begin // OUTPUT
            o_resultant_sum = sum;
            o_overflow = overflow;
            o_ready = 1;
            o_status = {1'b0, 1'b0};
            state <= 0;
        end
    endcase
end

always @(*) begin
    // Output status:
    o_status = {1'b0, o_ready};
end

endmodule
