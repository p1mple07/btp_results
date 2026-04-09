module signedadder #(parameter DATA_WIDTH = 8)(
    input         i_clk,
    input         i_rst_n,
    input         i_start,
    input         i_enable,
    input         i_mode,
    input         i_clear,
    input  [DATA_WIDTH-1:0] i_operand_a,
    input  [DATA_WIDTH-1:0] i_operand_b,
    output reg [DATA_WIDTH-1:0] o_resultant_sum,
    output reg           o_overflow,
    output reg           o_ready,
    output reg  [1:0]    o_status
);

    // State encoding
    localparam IDLE   = 2'b00;
    localparam LOAD   = 2'b01;
    localparam COMPUTE = 2'b10;
    localparam OUTPUT = 2'b11;

    // Internal registers to hold operands and computation result
    reg [DATA_WIDTH-1:0] operand_a_reg;
    reg [DATA_WIDTH-1:0] operand_b_reg;
    reg [DATA_WIDTH-1:0] result_reg;
    reg                   ovf_reg; // Overflow flag register

    // State register
    reg [1:0] state;

    // Sequential logic: asynchronous reset and synchronous operation
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
        end
        // i_clear: resets outputs and state machine
        else if (i_clear) begin
            state            <= IDLE;
            operand_a_reg    <= {DATA_WIDTH{1'b0}};
            operand_b_reg    <= {DATA_WIDTH{1'b0}};
            result_reg       <= {DATA_WIDTH{1'b0}};
            o_resultant_sum  <= {DATA_WIDTH{1'b0}};
            o_overflow       <= 1'b0;
            o_ready          <= 1'b0;
            o_status         <= IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    // Wait for start signal when enabled
                    if (i_start && i_enable)
                        state <= LOAD;
                    o_ready   <= 1'b0;
                    o_status  <= IDLE;
                end

                LOAD: begin
                    // Capture the input operands
                    operand_a_reg <= i_operand_a;
                    operand_b_reg <= i_operand_b;
                    state        <= COMPUTE;
                    o_status     <= LOAD;
                end

                COMPUTE: begin
                    // Perform addition or subtraction based on i_mode
                    if (i_mode)
                        result_reg <= operand_a_reg - operand_b_reg;  // Subtraction
                    else
                        result_reg <= operand_a_reg + operand_b_reg;  // Addition

                    // Overflow detection:
                    // Overflow occurs if both operands have the same sign
                    // and the result has a different sign.
                    if ((operand_a_reg[DATA_WIDTH-1] == operand_b_reg[DATA_WIDTH-1]) &&
                        (result_reg[DATA_WIDTH-1]  != operand_a_reg[DATA_WIDTH-1]))
                        ovf_reg <= 1'b1;
                    else
                        ovf_reg <= 1'b0;
                    state     <= OUTPUT;
                    o_status  <= COMPUTE;
                end

                OUTPUT: begin
                    // Drive the outputs and signal that the result is ready
                    o_resultant_sum <= result_reg;
                    o_overflow      <= ovf_reg;
                    o_ready         <= 1'b1;
                    o_status        <= OUTPUT;
                    state           <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule