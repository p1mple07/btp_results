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
    enum reg [1:0] {
        IDLE,
        LOAD,
        COMPUTE,
        OUTPUT
    } state;
    reg [DATA_WIDTH-1:0] operand_a;
    reg [DATA_WIDTH-1:0] operand_b;
    reg [DATA_WIDTH-1:0] sum;
    
    always @(posedge i_clk or posedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= IDLE;
            operand_a <= 0;
            operand_b <= 0;
            sum <= 0;
            o_overflow <= 0;
            o_ready <= 0;
            o_status <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (i_start && i_enable) begin
                        state <= LOAD;
                    end
                end
                LOAD: begin
                    operand_a <= i_operand_a;
                    operand_b <= i_operand_b;
                    state <= COMPUTE;
                end
                COMPUTE: begin
                    case (i_mode)
                        0: sum <= operand_a + operand_b;
                        1: sum <= operand_a - operand_b;
                    endcase

                    if (sum[DATA_WIDTH-1]) begin
                        o_overflow <= 1;
                    end else begin
                        o_overflow <= 0;
                    end
                    
                    state <= OUTPUT;
                end
                OUTPUT: begin
                    o_resultant_sum <= sum;
                    o_ready <= 1;
                    o_status <= 4'b0011;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule