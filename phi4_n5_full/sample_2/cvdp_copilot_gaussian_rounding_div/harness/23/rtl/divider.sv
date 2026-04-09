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
    output wire [WIDTH-1 : 0]    quotient,   // Result of the division
    output wire [WIDTH-1 : 0]    remainder,  // Remainder after division
    output wire                  valid       // Indicates output is valid
);

    // one extra bit for A
    localparam AW = WIDTH + 1;
    // Combined A+Q register width
    localparam AQ_WIDTH = AW + WIDTH; // = 2*WIDTH + 1

    // FSM states
    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    // FSM and main registers
    reg [1:0] state_reg, state_next;
    reg [AQ_WIDTH-1:0] aq_reg, aq_next;
    reg [$clog2(WIDTH)-1:0] n_reg, n_next;
    // Combine quotient and remainder into one register to reduce area
    reg [2*WIDTH-1:0] result_reg, result_next;
    reg valid_reg, valid_next;

    // Instead of storing the extended divisor in a register, compute it combinatorially.
    // m_comb represents {1'b0, divisor} (i.e. divisor zero‐extended to AW bits)
    wire [WIDTH-1:0] m_comb;
    assign m_comb = {1'b0, divisor};

    // Top-level outputs
    assign quotient  = result_reg[WIDTH-1:0];
    assign remainder = result_reg[2*WIDTH-1:WIDTH];
    assign valid     = valid_reg;

    //------------------------------------------------
    // SEQUENTIAL: State & register updates
    //------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg     <= IDLE;
            aq_reg        <= 0;
            n_reg         <= 0;
            result_reg    <= 0;
            valid_reg     <= 0;
        end else begin
            state_reg     <= state_next;
            aq_reg        <= aq_next;
            n_reg         <= n_next;
            result_reg    <= result_next;
            valid_reg     <= valid_next;
        end
    end

    //------------------------------------------------
    // COMBINATIONAL: Next-state logic
    //------------------------------------------------
    always @* begin
        // Default: hold current values and state
        state_next     = state_reg;
        aq_next        = aq_reg;
        n_next         = n_reg;
        result_next    = result_reg;
        valid_next     = valid_reg;

        case (state_reg)
        //---------------------------------------------
        // IDLE: Wait for start signal
        //---------------------------------------------
        IDLE: begin
            valid_next = 1'b0;
            if (start) begin
                // Initialize:
                // A = 0  --> upper AW bits zero
                // Q = dividend  --> lower WIDTH bits
                // Thus, AQ = { {AW{1'b0}}, dividend }
                aq_next = { {AW{1'b0}}, dividend };
                // Set iteration counter to process all WIDTH bits
                n_next  = WIDTH;
                // Initialize combined result to zero
                result_next = 0;
                // Transition to BUSY state
                state_next = BUSY;
            end
        end

        //---------------------------------------------
        // BUSY: Perform one iteration of non-restoring division
        //---------------------------------------------
        BUSY: begin
            // Shift AQ left by one bit
            aq_next = aq_reg << 1;
            // Conditional add/subtract on the A portion (upper bits)
            if (aq_reg[AQ_WIDTH-1] == 1'b1) begin
                aq_next[AQ_WIDTH-1:WIDTH] = aq_next[AQ_WIDTH-1:WIDTH] + m_comb;
            end else begin
                aq_next[AQ_WIDTH-1:WIDTH] = aq_next[AQ_WIDTH-1:WIDTH] - m_comb;
            end
            // Set new Q[0] as the complement of the sign bit of A
            aq_next[0] = ~aq_reg[AQ_WIDTH-1];

            // Decrement the iteration counter
            n_next = n_reg - 1;

            // If all iterations are done, move to DONE state
            if (n_next == 0)
                state_next = DONE;
        end

        //---------------------------------------------
        // DONE: Final correction and output preparation
        //---------------------------------------------
        DONE: begin
            // Final correction: if sign bit of A is 1, add m_comb to A portion
            if (aq_reg[AQ_WIDTH-1] == 1'b1) begin
                result_next = aq_reg;
                result_next[AQ_WIDTH-1:WIDTH] = aq_reg[AQ_WIDTH-1:WIDTH] + m_comb;
            end else begin
                result_next = aq_reg;
            end
            valid_next = 1'b1;

            // Return to IDLE if start de-asserts; otherwise, remain in DONE for chaining
            if (!start)
                state_next = IDLE;
            else
                state_next = DONE;
        end

        default: begin
            state_next = IDLE;
        end
        endcase
    end

endmodule