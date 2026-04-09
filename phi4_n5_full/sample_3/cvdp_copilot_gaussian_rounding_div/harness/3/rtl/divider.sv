
module divider #
(
    parameter WIDTH = 32
)
(
    input  wire                  clk,
    input  wire                  rst_n,      // Active-low asynchronous reset
    input  wire                  start,      // Start signal for new operation
    input  wire [WIDTH-1 : 0]    dividend,   // Dividend (numerator)
    input  wire [WIDTH-1 : 0]    divisor,    // Divisor (denominator)
    output reg [WIDTH-1 : 0]     quotient,   // Result of the division
    output reg [WIDTH-1 : 0]     remainder,  // Remainder after division
    output reg                  valid       // Indicates output is valid
);

    localparam AW = WIDTH + 1;
    // Simple 3-state FSM
    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state_reg, state_next;

    // A+Q combined into one (AW + WIDTH) register:
    reg [AW + WIDTH - 1 : 0] aq_reg, aq_next;

    // Divisor register
    reg [AW - 1 : 0] m_reg, m_next;

    // Iterate exactly WIDTH times
    reg [$clog2(WIDTH)-1:0] n_reg, n_next;

    // Final outputs
    reg [WIDTH-1:0] quotient_reg, quotient_next;
    reg [WIDTH-1:0] remainder_reg, remainder_next;
    reg valid_reg, valid_next;

    // Next state and output logic
    always @(*) begin
        // Default assignments
        state_next = state_reg;
        aq_next = aq_reg;
        m_next = m_reg;
        n_next = n_reg;
        quotient_next = quotient_reg;
        remainder_next = remainder_reg;
        valid_next = valid_reg;

        case (state_reg)
            IDLE: begin
                if (start) begin
                    // Load registers for new operation
                    aq_next = { {1'b0}, dividend, {WIDTH{1'b0}} }; // A = 0, Q = dividend
                    m_next = divisor;
                    n_next = WIDTH;
                    quotient_next = 0;
                    remainder_next = 0;
                    valid_next = 0;
                    state_next = BUSY;
                end
            end

            BUSY: begin
                if (n_reg != 0) begin
                    // Extract old sign bit of A (MSB of A)
                    wire old_sign = aq_reg[AW + WIDTH - 1]; // aq_reg[2*WIDTH] because AW+WIDTH-1 = (WIDTH+1)+WIDTH-1 = 2*WIDTH
                    // Shift left AQ: new A = (A << 1), new Q = (Q << 1)
                    // A is aq_reg[AW+WIDTH-1 : WIDTH] (WIDTH+1 bits)
                    wire [AW-1:0] A_shifted = aq_reg[AW+WIDTH-1:WIDTH] << 1;
                    // Extend m_reg to AW bits (WIDTH+1 bits)
                    wire [AW-1:0] m_ext = {1'b0, m_reg};
                    wire [AW-1:0] m_ext_neg = ~m_ext + 1;
                    // Perform arithmetic on A: if old_sign is 1 then add m_ext, else subtract m_ext
                    wire [AW-1:0] new_A = A_shifted + (old_sign ? m_ext : m_ext_neg);
                    // Determine new sign bit from new_A (MSB of new_A)
                    wire new_sign = new_A[AW-1]; // MSB of new_A
                    // Compute new quotient bit: Q[0] = ~new_sign
                    wire new_quotient_bit = ~new_sign;
                    // Shift left Q: Q is aq_reg[WIDTH-1:0]
                    wire [WIDTH-1:0] Q_shifted = aq_reg[WIDTH-1:0] << 1;
                    // Combine new A and new Q into new aq register
                    aq_next = { new_A, Q_shifted | new_quotient_bit };
                    n_next = n_reg - 1;
                    state_next = BUSY;
                end else begin
                    state_next = DONE;
                end
            end

            DONE: begin
                // Final adjustment: if sign bit of A is 1, then remainder = A + M, else remainder = A.
                if (aq_reg[AW+WIDTH-1]) begin
                    // A part is aq_reg[AW+WIDTH-1 : WIDTH], take lower WIDTH bits for remainder
                    remainder_next = aq_reg[WIDTH-1:0] + m_reg;
                end else begin
                    remainder_next = aq_reg[WIDTH-1:0];
                end
                // Quotient is the Q part of aq register
                quotient_next = aq_reg[WIDTH-1:0];
                valid_next = 1;
                // Stay in DONE until start is de-asserted
                if (!start) begin
                    state_next = IDLE;
                end
            end

            default: state_next = IDLE;
        endcase
    end

    // Sequential logic: update registers on clock edge
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg <= IDLE;
            aq_reg <= 0;
            m_reg <= 0;
            n_reg <= 0;
            quotient_reg <= 0;
            remainder_reg <= 0;
            valid_reg <= 0;
        end else begin
            state_reg <= state_next;
            aq_reg <= aq_next;
            m_reg <= m_next;
            n_reg <= n_next;
            quotient_reg <= quotient_next;
            remainder_reg <= remainder_next;
            valid_reg <= valid_next;
        end
    end

endmodule
