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
    reg overflow, state_reg;

    // State register
    always @(posedge i_clk or posedge i_rst_n) begin
        if (i_rst_n) begin
            state_reg <= 2'b00;
            a_reg <= 0;
            b_reg <= 0;
            o_resultant_sum <= 0;
            overflow <= 0;
            o_ready <= 0;
        end else begin
            case (state_reg)
                2'b00: if (i_start && i_enable) begin
                            state_reg <= 2'b01;
                            a_reg <= i_operand_a;
                            b_reg <= i_operand_b;
                        end
                2'b01: begin
                            state_reg <= (i_mode == 1) ? 2'b10 : 2'b01;
                        end
                2'b10: begin
                            if (i_mode == 1) begin
                                o_resultant_sum <= a_reg - b_reg;
                                overflow <= (a_reg[DATA_WIDTH-1] & b_reg[DATA_WIDTH-1] & ~a_reg[DATA_WIDTH-2] & ~b_reg[DATA_WIDTH-2]);
                            end else begin
                                o_resultant_sum <= a_reg + b_reg;
                                overflow <= (a_reg[DATA_WIDTH-1] & b_reg[DATA_WIDTH-1] & ~a_reg[DATA_WIDTH-2] & ~b_reg[DATA_WIDTH-2]);
                            end
                            o_ready <= 1;
                            state_reg <= (i_mode == 1) ? 2'b11 : 2'b00;
                        end
                        default: state_reg <= 2'b00;
                    end
            end
    end

    // Output logic
    always @(posedge i_clk) begin
        if (i_clear) begin
            state_reg <= 2'b00;
            o_resultant_sum <= 0;
            overflow <= 0;
            o_ready <= 0;
        end else if (o_ready) begin
            o_overflow <= overflow;
            o_resultant_sum <= o_resultant_sum;
            o_ready <= 0;
        end
    end

endmodule
