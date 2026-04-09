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

    // State encoding
    localparam IDLE   = 2'b00;
    localparam LOAD   = 2'b01;
    localparam COMPUTE= 2'b10;
    localparam OUTPUT = 2'b11;

    // Internal registers
    reg [1:0] state;
    reg [DATA_WIDTH-1:0] operand_a_reg;
    reg [DATA_WIDTH-1:0] operand_b_reg;
    reg [DATA_WIDTH-1:0] result_reg;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state            <= IDLE;
            operand_a_reg    <= {DATA_WIDTH{1'b0}};
            operand_b_reg    <= {DATA_WIDTH{1'b0}};
            result_reg       <= {DATA_WIDTH{1'b0}};
            o_resultant_sum  <= {DATA_WIDTH{1'b0}};
            o_overflow       <= 1'b0;
            o_ready          <= 1'b0;
            o_status         <= IDLE;
        end else begin
            if (i_clear) begin
                // Clear outputs and reset state
                state            <= IDLE;
                operand_a_reg    <= {DATA_WIDTH{1'b0}};
                operand_b_reg    <= {DATA_WIDTH{1'b0}};
                result_reg       <= {DATA_WIDTH{1'b0}};
                o_resultant_sum  <= {DATA_WIDTH{1'b0}};
                o_overflow       <= 1'b0;
                o_ready          <= 1'b0;
                o_status         <= IDLE;
            end else begin
                case (state)
                    IDLE: begin
                        // Wait for start signal and enable
                        if (i_enable && i_start)
                            state <= LOAD;
                        else
                            state <= IDLE;
                        o_status <= IDLE;
                        o_ready  <= 1'b0;
                    end
                    LOAD: begin
                        // Capture operands
                        state            <= COMPUTE;
                        operand_a_reg    <= i_operand_a;
                        operand_b_reg    <= i_operand_b;
                        o_status         <= LOAD;
                        o_ready          <= 1'b0;
                    end
                    COMPUTE: begin
                        // Perform addition or subtraction based on mode
                        state            <= OUTPUT;
                        result_reg       <= (i_mode ? operand_a_reg - operand_b_reg : operand_a_reg + operand_b_reg);
                        o_status         <= COMPUTE;
                        o_ready          <= 1'b0;
                    end
                    OUTPUT: begin
                        // Update outputs and check for overflow
                        state            <= IDLE;
                        o_resultant_sum  <= result_reg;
                        o_overflow       <= ((~operand_a_reg[DATA_WIDTH-1] & ~operand_b_reg[DATA_WIDTH-1] & result_reg[DATA_WIDTH-1]) |
                                            ( operand_a_reg[DATA_WIDTH-1] & operand_b_reg[DATA_WIDTH-1] & ~result_reg[DATA_WIDTH-1]));
                        o_ready          <= 1'b1;
                        o_status         <= OUTPUT;
                    end
                    default: state <= IDLE;
                endcase
            end
        end
    end

endmodule