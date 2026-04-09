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

    // Internal registers to hold operands and computation results
    reg [DATA_WIDTH-1:0] operand_a_reg;
    reg [DATA_WIDTH-1:0] operand_b_reg;
    reg [DATA_WIDTH-1:0] sum_reg;
    reg overflow_reg;
    reg [1:0] state;

    // Internal combinational wires for computation
    // Compute two's complement of operand_b when needed (for subtraction)
    wire [DATA_WIDTH-1:0] b_neg;
    assign b_neg = ~operand_b_reg + 1;

    // Compute the sum based on operation mode.
    // For addition: sum = operand_a_reg + operand_b_reg.
    // For subtraction: sum = operand_a_reg + b_neg.
    wire [DATA_WIDTH-1:0] sum_wire;
    assign sum_wire = operand_a_reg + (i_mode ? b_neg : operand_b_reg);

    // Overflow detection logic.
    // For addition:
    //   overflow occurs if (a and b are positive and result is negative) or
    //   (a and b are negative and result is positive).
    // For subtraction:
    //   overflow occurs if (signs of a and -b differ and sign of result differs from a).
    wire overflow_wire;
    assign overflow_wire = (i_mode ?
         // Subtraction overflow: (a[MSB] XOR (-b)[MSB]) AND (result[MSB] XOR a[MSB])
         ((operand_a_reg[DATA_WIDTH-1] ^ b_neg[DATA_WIDTH-1]) & (sum_wire[DATA_WIDTH-1] ^ operand_a_reg[DATA_WIDTH-1]))
       :
         // Addition overflow:
         ((operand_a_reg[DATA_WIDTH-1] & operand_b_reg[DATA_WIDTH-1] & ~sum_wire[DATA_WIDTH-1]) |
          (~operand_a_reg[DATA_WIDTH-1] & ~operand_b_reg[DATA_WIDTH-1] & sum_wire[DATA_WIDTH-1]))
    );

    // Synchronous state machine with asynchronous reset and clear.
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state           <= IDLE;
            operand_a_reg   <= {DATA_WIDTH{1'b0}};
            operand_b_reg   <= {DATA_WIDTH{1'b0}};
            sum_reg         <= {DATA_WIDTH{1'b0}};
            overflow_reg    <= 1'b0;
            o_resultant_sum <= {DATA_WIDTH{1'b0}};
            o_overflow      <= 1'b0;
            o_ready         <= 1'b0;
            o_status        <= IDLE;
        end
        else if (i_clear) begin
            state           <= IDLE;
            operand_a_reg   <= {DATA_WIDTH{1'b0}};
            operand_b_reg   <= {DATA_WIDTH{1'b0}};
            sum_reg         <= {DATA_WIDTH{1'b0}};
            overflow_reg    <= 1'b0;
            o_resultant_sum <= {DATA_WIDTH{1'b0}};
            o_overflow      <= 1'b0;
            o_ready         <= 1'b0;
            o_status        <= IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    o_ready  <= 1'b0;
                    o_status <= IDLE;
                    // Wait for start signal while enable is high.
                    if (i_start && i_enable) begin
                        state <= LOAD;
                    end
                end
                LOAD: begin
                    o_status <= LOAD;
                    // Capture input operands.
                    operand_a_reg <= i_operand_a;
                    operand_b_reg <= i_operand_b;
                    state <= COMPUTE;
                end
                COMPUTE: begin
                    o_status <= COMPUTE;
                    // Perform the arithmetic operation.
                    sum_reg     <= sum_wire;
                    overflow_reg<= overflow_wire;
                    state <= OUTPUT;
                end
                OUTPUT: begin
                    o_status <= OUTPUT;
                    // Drive outputs with computed results.
                    o_resultant_sum <= sum_reg;
                    o_overflow      <= overflow_reg;
                    o_ready          <= 1'b1;
                    // Return to IDLE for the next operation.
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule