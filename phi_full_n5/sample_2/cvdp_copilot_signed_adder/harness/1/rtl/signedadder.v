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

    // State logic
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            status <= 2'b00;
            o_resultant_sum <= {DATA_WIDTH{1'b0}};
            o_overflow <= 0;
            o_ready <= 0;
        end else begin
            case (status)
                2'b00: if (i_start) begin
                            status <= 2'b01;
                            a_reg <= i_operand_a;
                            b_reg <= i_operand_b;
                        end
                2'b01: begin
                            if (i_clear) begin
                                status <= 2'b00;
                                a_reg <= {DATA_WIDTH{1'b0}};
                                b_reg <= {DATA_WIDTH{1'b0}};
                            end
                            status <= 2'b10;
                        end
                2'b10: begin
                            if (i_mode == 0) begin
                                o_resultant_sum <= a_reg + b_reg;
                                o_overflow <= (a_reg[DATA_WIDTH-1] & b_reg[DATA_WIDTH-1] &
                                                (~a_reg[DATA_WIDTH-2] | ~b_reg[DATA_WIDTH-2]));
                            end else if (i_mode == 1) begin
                                o_resultant_sum <= a_reg - b_reg;
                                o_overflow <= (a_reg[DATA_WIDTH-1] & b_reg[DATA_WIDTH-1] &
                                                (~a_reg[DATA_WIDTH-2] | ~b_reg[DATA_WIDTH-2]));
                            end
                            o_ready <= 1;
                            status <= 2'b11;
                        end
                2'b11: begin
                            o_resultant_sum <= o_resultant_sum;
                            o_overflow <= o_overflow;
                            o_ready <= o_ready;
                            status <= 2'b00;
                        end
                    end
        end
    end

endmodule
