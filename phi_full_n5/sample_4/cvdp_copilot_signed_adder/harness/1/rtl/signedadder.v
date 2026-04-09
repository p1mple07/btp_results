module signedadder #(parameter DATA_WIDTH = 8)(
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
    // Internal registers
    reg [DATA_WIDTH-1:0] a_reg, b_reg;
    reg [1:0] status;
    reg overflow_flag;

    // State machine
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            status <= 0;
            a_reg <= 0;
            b_reg <= 0;
            o_overflow <= 0;
            o_resultant_sum <= 0;
            o_ready <= 0;
        end else begin
            case (status)
                0: begin
                    if (i_start) begin
                        a_reg <= i_operand_a;
                        b_reg <= i_operand_b;
                        status <= 1;
                    end
                end
                1: begin
                    if (i_enable) begin
                        if (i_mode == 0) begin
                            o_resultant_sum <= a_reg + b_reg;
                            overflow_flag = (a_reg[DATA_WIDTH-1] & b_reg[DATA_WIDTH-1]) |
                                            ((!a_reg[DATA_WIDTH-1]) & (b_reg[DATA_WIDTH-1] ^ a_reg[DATA_WIDTH-1]));
                        end else if (i_mode == 1) begin
                            o_resultant_sum <= a_reg - b_reg;
                            overflow_flag = (a_reg[DATA_WIDTH-1] ^ b_reg[DATA_WIDTH-1]) |
                                            (!a_reg[DATA_WIDTH-1] & b_reg[DATA_WIDTH-1]);
                        end
                        o_overflow <= overflow_flag;
                        o_ready <= 1;
                        status <= 11;
                    end
                end
                11: begin
                    o_overflow <= overflow_flag;
                    o_ready <= 1;
                    status <= 0;
                end
            endcase
        end
    end

    // Output logic
    assign o_resultant_sum = (i_clear) ? 0 : o_resultant_sum;
    assign o_overflow = (i_clear) | o_overflow;
    assign o_ready = (i_clear) | o_ready;

endmodule
