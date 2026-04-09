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

    // One extra bit for A
    localparam AW = WIDTH + 1;
    // FSM states
    localparam IDLE = 2'd0;
    localparam BUSY = 2'd1;
    localparam DONE = 2'd2;

    // Combined register for A and Q (A is upper AW bits, Q is lower WIDTH bits)
    reg [AW+WIDTH-1:0] aq;
    // Divisor register (zero‐extended to AW bits)
    reg [AW-1:0] m;
    // Iteration counter (number of bits in dividend)
    reg [$clog2(WIDTH)-1:0] n;
    // Registered outputs
    reg [WIDTH-1:0] quotient_reg;
    reg [WIDTH-1:0] remainder_reg;
    reg valid_reg;

    // Output assignments
    assign quotient  = quotient_reg;
    assign remainder = remainder_reg;
    assign valid     = valid_reg;

    //--------------------------------------------------------------------------
    // Merged sequential and next-state logic to reduce area by eliminating
    // intermediate next-state registers and combinational logic.
    //--------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            aq         <= 0;
            m          <= 0;
            n          <= 0;
            quotient_reg <= 0;
            remainder_reg <= 0;
            valid_reg  <= 0;
        end
        else begin
            case (state)
                // IDLE: Wait for start signal; initialize registers when start is asserted.
                IDLE: begin
                    valid_reg <= 1'b0;
                    if (start) begin
                        // Initialize: A = 0, Q = dividend, M = divisor (zero‐extended)
                        aq      <= { {AW{1'b0}}, dividend };
                        m       <= {1'b0, divisor};
                        n       <= WIDTH;
                        state   <= BUSY;
                    end
                end

                // BUSY: Perform one iteration of the non-restoring division.
                BUSY: begin
                    // Use the old value of aq (due to non‐blocking assignments) for decision.
                    // Shift left the combined register.
                    aq <= { aq[AW+WIDTH-1:WIDTH] + (aq[AW+WIDTH-1] ? m : -m),
                            aq[WIDTH-1:0] };
                    // Set Q[0] to the complement of the old sign bit of A.
                    aq[0] <= ~aq[AW+WIDTH-1];
                    n <= n - 1;
                    if (n == 0)
                        state <= DONE;
                    else
                        state <= BUSY;
                end

                // DONE: Final correction and output assignment.
                DONE: begin
                    // Final correction: if sign bit of A is 1, add M to A.
                    remainder_reg <= aq[2*WIDTH-1:WIDTH] + (aq[AW+WIDTH-1] ? m : 0);
                    quotient_reg  <= aq[WIDTH-1:0];
                    valid_reg     <= 1'b1;
                    // Remain in DONE until start deasserts; then return to IDLE.
                    if (!start)
                        state <= IDLE;
                    else
                        state <= DONE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule