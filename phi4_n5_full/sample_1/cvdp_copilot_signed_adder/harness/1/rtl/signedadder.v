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
    localparam COMPUTE = 2'b10;
    localparam OUTPUT  = 2'b11;

    // Internal registers for operands and computation
    reg [DATA_WIDTH-1:0] op_a_reg;
    reg [DATA_WIDTH-1:0] op_b_reg;
    reg [DATA_WIDTH-1:0] result_reg;
    reg overflow_reg;
    reg [1:0] state;

    // State machine process
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Asynchronous reset: set state and outputs to initial values
            state            <= IDLE;
            op_a_reg         <= {DATA_WIDTH{1'b0}};
            op_b_reg         <= {DATA_WIDTH{1'b0}};
            result_reg       <= {DATA_WIDTH{1'b0}};
            overflow_reg     <= 1'b0;
            o_resultant_sum  <= {DATA_WIDTH{1'b0}};
            o_overflow       <= 1'b0;
            o_ready          <= 1'b0;
            o_status         <= IDLE;
        end else begin
            if (i_clear) begin
                // Clear outputs and reset state machine when i_clear is asserted
                state            <= IDLE;
                op_a_reg         <= {DATA_WIDTH{1'b0}};
                op_b_reg         <= {DATA_WIDTH{1'b0}};
                result_reg       <= {DATA_WIDTH{1'b0}};
                overflow_reg     <= 1'b0;
                o_resultant_sum  <= {DATA_WIDTH{1'b0}};
                o_overflow       <= 1'b0;
                o_ready          <= 1'b0;
                o_status         <= IDLE;
            end else begin
                case (state)
                    IDLE: begin
                        // Wait for start signal and enable to load operands
                        if (i_enable && i_start) begin
                            state <= LOAD;
                        end
                        // Remain in IDLE otherwise
                    end

                    LOAD: begin
                        // Capture the input operands
                        op_a_reg <= i_operand_a;
                        op_b_reg <= i_operand_b;
                        state    <= COMPUTE;
                    end

                    COMPUTE: begin
                        // Perform addition or subtraction based on i_mode
                        if (i_mode == 1'b0) begin
                            // Addition: o_resultant_sum = op_a_reg + op_b_reg
                            result_reg <= op_a_reg + op_b_reg;
                            // Overflow detection for addition:
                            // Overflow when both operands have the same sign as the result.
                            overflow_reg <= ((op_a_reg[DATA_WIDTH-1] & op_b_reg[DATA_WIDTH-1] & ~result_reg[DATA_WIDTH-1]) |
                                             (~op_a_reg[DATA_WIDTH-1] & ~op_b_reg[DATA_WIDTH-1] & result_reg[DATA_WIDTH-1]));
                        end else begin
                            // Subtraction: a - b = a + (~b + 1)
                            result_reg <= op_a_reg + (~op_b_reg + 1);
                            // Overflow detection for subtraction:
                            // Overflow when the sign of a and b differ from the sign of the result.
                            overflow_reg <= ((op_a_reg[DATA_WIDTH-1] & ~op_b_reg[DATA_WIDTH-1] & ~result_reg[DATA_WIDTH-1]) |
                                             (~op_a_reg[DATA_WIDTH-1] & op_b_reg[DATA_WIDTH-1] & result_reg[DATA_WIDTH-1]));
                        end
                        state <= OUTPUT;
                    end

                    OUTPUT: begin
                        // Drive outputs and indicate computation is complete
                        o_resultant_sum <= result_reg;
                        o_overflow      <= overflow_reg;
                        o_ready         <= 1'b1;
                        state           <= IDLE;
                    end

                    default: state <= IDLE;
                endcase
            end
        end
    end

    // Drive the status output to reflect the current state
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            o_status <= IDLE;
        else
            o_status <= state;
    end

endmodule