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

    parameter MIN_VALUE = -((2**DATA_WIDTH)-1);
    parameter MAX_VALUE = ((2**DATA_WIDTH)-1);

    reg [DATA_WIDTH-1:0] r_operand_a;
    reg [DATA_WIDTH-1:0] r_operand_b;
    reg [DATA_WIDTH-1:0] r_resultant_sum;
    reg r_sign_a;
    reg r_sign_b;
    reg r_sign_sum;
    reg r_overflow;
    reg r_ready;
    reg [1:0] r_state;

    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            r_operand_a <= 0;
            r_operand_b <= 0;
            r_resultant_sum <= 0;
            r_sign_a <= 0;
            r_sign_b <= 0;
            r_sign_sum <= 0;
            r_overflow <= 0;
            r_ready <= 0;
            r_state <= 2'b00;
        end else begin
            case(r_state)
                2'b00: begin
                    if (i_enable && i_start) begin
                        r_operand_a <= i_operand_a;
                        r_operand_b <= i_operand_b;
                        r_sign_a <= (i_operand_a[DATA_WIDTH-1] == 1);
                        r_sign_b <= (i_operand_b[DATA_WIDTH-1] == 1);
                        r_sign_sum <= 0;
                        r_state <= 2'b01;
                    end
                end
                2'b01: begin
                    r_resultant_sum <= {r_sign_sum, i_operand_a} + {r_sign_b, i_operand_b};
                    if (r_resultant_sum[DATA_WIDTH]!= r_sign_sum || r_resultant_sum[DATA_WIDTH+1]!= r_sign_sum) begin
                        r_overflow <= 1;
                    end else begin
                        r_overflow <= 0;
                    }
                    if (i_clear) begin
                        r_operand_a <= 0;
                        r_operand_b <= 0;
                        r_sign_a <= 0;
                        r_sign_b <= 0;
                        r_sign_sum <= 0;
                        r_overflow <= 0;
                        r_ready <= 0;
                        r_state <= 2'b00;
                    end else begin
                        r_ready <= 1;
                        r_state <= 2'b10;
                    end
                end
                2'b10: begin
                    o_resultant_sum <= r_resultant_sum;
                    o_overflow <= r_overflow;
                    o_ready <= r_ready;
                    r_state <= 2'b11;
                end
                2'b11: begin
                    r_ready <= 0;
                    r_state <= 2'b00;
                end
            endcase
        end
    end

endmodule