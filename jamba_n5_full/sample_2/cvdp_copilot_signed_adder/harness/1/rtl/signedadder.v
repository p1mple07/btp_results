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

localparam IDLE = 2'd0, LOAD = 2'd1, COMPUTE = 2'd2, OUTPUT = 2'd3;

always @(posedge i_clk or i_start) begin
    if (i_rst_n) begin
        state <= IDLE;
        o_resultant_sum <= 0;
        o_overflow <= 0;
        o_ready <= 0;
        o_status <= {1'b0, 1'b0};
    end else if (i_enable && state == IDLE) begin
        state <= LOAD;
    end else if (state == LOAD) begin
        o_ready <= 0;
        o_resultant_sum <= i_operand_a;
        o_overflow <= 0;
        o_ready <= 1;
        state <= COMPUTE;
    end else if (state == COMPUTE) begin
        o_ready <= 0;
        if (i_mode == 0) begin
            // Addition
            o_overflow = (i_operand_a[DATA_WIDTH-1] ^ i_operand_b[DATA_WIDTH-1]) & (i_operand_a[DATA_WIDTH-1] & ~i_operand_b[DATA_WIDTH-1]);
            o_resultant_sum = i_operand_a ^ i_operand_b;
        end else begin
            // Subtraction: a - b = a + ~b + 1
            o_overflow = (i_operand_a[DATA_WIDTH-1] ^ i_operand_b[DATA_WIDTH-1]) & (i_operand_a[DATA_WIDTH-1] & ~i_operand_b[DATA_WIDTH-1]);
            o_resultant_sum = i_operand_a ^ (~i_operand_b + 1);
        end
        o_ready <= 1;
    end else if (state == OUTPUT) begin
        o_ready <= 1;
        state <= IDLE;
    end
end

always @(negedge i_clk) begin
    if (i_rst_n) begin
        state <= IDLE;
    end else if (i_start) begin
        state <= LOAD;
    end
end

endmodule
