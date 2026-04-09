module divider #
(
    parameter WIDTH = 32
)
(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [WIDTH-1:0]      dividend,
    input  wire [WIDTH-1:0]      divisor,
    output wire [WIDTH-1:0]      quotient,
    output wire [WIDTH-1:0]      remainder,
    output wire                  valid
);

    // Parameters and FSM states
    localparam AW = WIDTH + 1;
    localparam IDLE = 2'b00, BUSY = 2'b01, DONE = 2'b10;

    // Registers for state and arithmetic
    reg [1:0] state_reg, state_next;
    reg [AW+WIDTH-1:0] aq_reg, aq_next;
    reg [AW-1:0] m_reg, m_next;
    reg [$clog2(WIDTH)-1:0] n_reg, n_next;
    reg [WIDTH-1:0] quotient_reg, quotient_next;
    reg [WIDTH-1:0] remainder_reg, remainder_next;
    reg valid_reg, valid_next;

    // Top-level output assignments
    assign quotient  = quotient_reg;
    assign remainder = remainder_reg;
    assign valid     = valid_reg;

    //-------------------------------------------------------------------------
    // Sequential logic: update registers on clock edge or asynchronous reset
    //-------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg     <= IDLE;
            aq_reg        <= 0;
            m_reg         <= 0;
            n_reg         <= 0;
            quotient_reg  <= 0;
            remainder_reg <= 0;
            valid_reg     <= 0;
        end else begin
            state_reg     <= state_next;
            aq_reg        <= aq_next;
            m_reg         <= m_next;
            n_reg         <= n_next;
            quotient_reg  <= quotient_next;
            remainder_reg <= remainder_next;
            valid_reg     <= valid_next;
        end
    end

    //-------------------------------------------------------------------------
    // Combinational logic: compute next state and outputs
    //-------------------------------------------------------------------------
    always @* begin
        // Default assignments
        state_next     = state_reg;
        aq_next        = aq_reg;
        m_next         = m_reg;
        n_next         = n_reg;
        quotient_next  = quotient_reg;
        remainder_next = remainder_reg;
        valid_next     = valid_reg;

        case (state_reg)
            // IDLE: Wait for start signal
            IDLE: begin
                valid_next = 1'b0;
                if (start) begin
                    // Initialize: A = 0, Q = dividend, M = divisor, N = WIDTH
                    aq_next = { {AW{1'b0}}, dividend };
                    m_next   = {1'b0, divisor};
                    n_next   = WIDTH;
                    state_next = BUSY;
                end
            end

            // BUSY: Perform iterative division steps
            BUSY: begin
                // Combine shift and conditional add/subtract using automatic variables
                automatic logic [AW-1:0] temp_upper;
                automatic logic [WIDTH-1:0] temp_lower;
                { temp_upper, temp_lower } = aq_reg << 1;
                automatic logic [AW-1:0] new_upper = temp_upper + (aq_reg[AW+WIDTH-1] ? m_reg : -m_reg);
                // Reconstruct AQ: upper part is new_upper, lower part remains shifted Q
                aq_next = { new_upper, temp_lower };
                // Set Q[0] based on the MSB of the new upper part (A)
                aq_next[0] = ~new_upper[AW-1];
                n_next = n_reg - 1;
                if (n_next == 0)
                    state_next = DONE;
            end

            // DONE: Final correction and output assignment
            DONE: begin
                // Final correction: if sign bit of A is 1, add M
                aq_next = aq_reg + (aq_reg[AW+WIDTH-1] ? m_reg : 0);
                // Q contains quotient (lower bits) and A contains remainder (upper bits)
                quotient_next  = aq_next[WIDTH-1:0];
                remainder_next = aq_next[2*WIDTH-1:WIDTH];
                valid_next = 1'b1;
                // Remain in DONE until start deasserts; then return to IDLE
                state_next = (!start) ? IDLE : DONE;
            end

            // Default: reset state
            default: begin
                state_next = IDLE;
            end
        endcase
    end

endmodule