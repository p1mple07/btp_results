module divider #(
    parameter WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [WIDTH-1:0]      dividend,
    input  wire [WIDTH-1:0]      divisor,
    output reg [WIDTH-1:0]       quotient,
    output reg [WIDTH-1:0]       remainder,
    output reg                  valid
);

    // One extra bit for A; total width for AQ = A+Q
    localparam AW = WIDTH + 1;
    // FSM states
    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    // Registered variables
    reg [1:0] state;
    reg [AW+WIDTH-1:0] aq;       // Combined A and Q register
    reg [AW-1:0] m;             // Divisor register (extended to AW bits)
    reg [$clog2(WIDTH)-1:0] n;   // Iteration counter

    // Merging sequential and combinational logic into one always block reduces extra registers and interconnect.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            aq         <= 0;
            m          <= 0;
            n          <= 0;
            quotient   <= 0;
            remainder  <= 0;
            valid      <= 0;
        end else begin
            case (state)
                //--------------------------------------------------------------------------
                // IDLE: Wait for start signal; initialize registers when start is asserted.
                //--------------------------------------------------------------------------
                IDLE: begin
                    if (start) begin
                        // Initialize:
                        // A = 0  --> upper AW bits zero; Q = dividend --> lower WIDTH bits.
                        aq <= { {AW{1'b0}}, dividend };
                        // Zero-extend divisor into AW bits.
                        m  <= {1'b0, divisor};
                        // Set iteration count to WIDTH.
                        n  <= WIDTH;
                        // Transition to BUSY state.
                        state <= BUSY;
                    end
                end

                //--------------------------------------------------------------------------
                // BUSY: Perform one iteration of the non-restoring division.
                //--------------------------------------------------------------------------
                BUSY: begin
                    // Shift AQ left by 1.
                    logic [AW+WIDTH-1:0] shifted;
                    shifted = aq << 1;
                    
                    // Split the shifted value into top (former A) and bottom (former Q).
                    logic [AW-1:0] top, corrected_top;
                    logic [WIDTH-1:0] bot, new_bot;
                    top    = shifted[AW+WIDTH-1: WIDTH];
                    bot    = shifted[WIDTH-1:0];

                    // Depending on the sign bit of A (MSB of aq), add or subtract M.
                    corrected_top = (aq[AW+WIDTH-1] ? top + m : top - m);

                    // Reconstruct new AQ: use corrected top and the shifted bottom.
                    // Also, set the LSB of Q (bit 0 of bot) to the complement of the sign bit.
                    new_bot = bot;
                    new_bot[0] = ~corrected_top[AW-1];

                    // Update AQ with the new combined value.
                    aq <= { corrected_top, new_bot };

                    // Decrement the iteration counter.
                    n <= n - 1;
                    if (n == 0)
                        state <= DONE;
                    else
                        state <= BUSY;
                end

                //--------------------------------------------------------------------------
                // DONE: Final correction and output generation.
                //--------------------------------------------------------------------------
                DONE: begin
                    // Final correction: if sign bit of A is 1, add M to the upper part.
                    logic [AW+WIDTH-1:0] final_aq;
                    final_aq = (aq[AW+WIDTH-1] ? { aq[AW+WIDTH-1: WIDTH] + m, aq[WIDTH-1:0] } : aq);

                    // The quotient is the lower WIDTH bits and the remainder is the upper WIDTH bits.
                    quotient <= final_aq[WIDTH-1:0];
                    remainder <= final_aq[2*WIDTH-1: WIDTH];
                    valid <= 1'b1;

                    // If start de-asserts, return to IDLE; otherwise, remain in DONE.
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