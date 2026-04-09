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

    localparam AW = WIDTH + 1;
    // Simple 3-state FSM
    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state_reg, state_next;

    // A+Q combined into one WIDTH + 1 + WIDTH register:
    reg [AW+WIDTH-1 : 0] aq_reg,   aq_next;

    // Divisor register
    reg [AW-1 : 0]       m_reg,    m_next;

    // Iterate exactly WIDTH times
    reg [$clog2(WIDTH)-1:0] n_reg, n_next;

    // Final outputs
    reg [WIDTH-1:0] quotient_reg, quotient_next;
    reg [WIDTH-1:0] remainder_reg, remainder_next;
    reg valid_reg, valid_next;

// Insert code here for non-restoring division algorithm
// Please write down the non-restoring division algorithm here

endmodule