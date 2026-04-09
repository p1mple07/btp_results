module divider #
(
    parameter WIDTH = 32
)
(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [WIDTH-1 : 0]    dividend,
    input  wire [WIDTH-1 : 0]    divisor,
    output wire [WIDTH-1 : 0]   quotient,
    output wire [WIDTH-1 : 0]   remainder,
    output wire                  valid
);

    // one extra bit for A
    localparam AW = WIDTH + 1;
    // Simple 3-state FSM
    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state_reg, state_next;

    // Divisor register
    reg [AW-1 : 0]       m_reg,    m_next;

    // Iterate exactly WIDTH times
    reg [$clog2(WIDTH)-1:0] n_reg, n_next;

    // Final outputs
    reg [WIDTH-1:0] quotient_reg, quotient_next;
    reg [WIDTH-1:0] remainder_reg, remainder_next;
    reg valid_reg, valid_next;

    // Assign the top-level outputs
    assign quotient  = quotient_reg;
    assign remainder = remainder_reg;
    assign valid     = valid_reg;

    //------------------------------------------------
    // SEQUENTIAL: State & register updates
    //------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg     <= IDLE;
            aq_reg        <= 0;
            m_reg         <= 0;
            n_reg         <= 0;
            quotient_reg  <= 0;
            remainder_reg <= 0;
            valid_reg     <= 0;
        end
        else begin
            state_reg     <= state_next;
            aq_reg        <= aq_next;
            m_reg         <= m_next;
            n_reg         <= n_next;
            quotient_reg  <= quotient_next;
            remainder_reg <= remainder_next;
            valid_reg     <= valid_next;
        end
    end

    //------------------------------------------------
    // COMBINATIONAL: Next-state logic
    //------------------------------------------------
    always @* begin
        case (state_reg)
        //---------------------------------------------
        // IDLE: Wait for start
        //---------------------------------------------
        IDLE: begin
            // Outputs not valid yet
            valid_next = 1'b0;

            if (start) begin
                // Step-1: Initialize
                // A = 0 => upper AW bits all zero
                // Q = dividend => lower WIDTH bits of aq
                // so zero‐extend: { (AW)'b0, dividend }
                aq_next = { (AW{1'b0}), dividend };
                // zero‐extend divisor into AW bits
                m_next   = {1'b0, divisor};
                n_next   = WIDTH;
                // We do not set the final quotient/remainder yet
                // Move to BUSY
                state_next = BUSY;
            end
        end

        //---------------------------------------------
        // BUSY: Perform the N iterations
        //---------------------------------------------
        BUSY: begin
            // 1) SHIFT LEFT
            aq_next = aq_reg << 1;

            // 2) Add or subtract M based on sign bit
            aq_next[AW+WIDTH-1 : WIDTH] = (aq_reg[AW+WIDTH-1] == 1'b1) ? aq_reg[AW+WIDTH-1 : WIDTH] + m_reg : aq_reg[AW+WIDTH-1 : WIDTH] - m_reg;

            // 3) Set quotient sign bit
            quotient_next[0] = (aq_reg[AW+WIDTH-1] == 1'b1) ? 1'b0 : 1'b1;

            // Decrement iteration count
            n_next = n_reg - 1;

            // Step-7: if n != 0 => repeat, else => next step
            if (n_next == 0) begin
                state_next = DONE;
            end
        end

        //---------------------------------------------
        // DONE: Final correction + output
        //---------------------------------------------
        DONE: begin
            // Step-8: If sign bit of A == 1 => A = A + M
            if (aq_reg[AW+WIDTH-1] == 1'b1) begin
                aq_next = aq_reg;  // default
                aq_next[AW+WIDTH-1 : WIDTH] = aq_reg[AW+WIDTH-1 : WIDTH] + m_reg;
            end

            // Step-9:
            //   - The final quotient is the lower WIDTH bits of aq_reg
            //   - The final remainder is the upper WIDTH bits of aq_reg
            quotient_next  = aq_next[WIDTH-1 : 0];
            remainder_next = aq_next[2*WIDTH-1 : WIDTH];

            // Output becomes valid
            valid_next = 1'b1;

            // Return to IDLE when 'start' goes low
            if (!start) begin
                state_next = IDLE;
            end else begin
                state_next = DONE;
            end
        end

        default: begin
            state_next = IDLE;
        end
        endcase
    end

endmodule
