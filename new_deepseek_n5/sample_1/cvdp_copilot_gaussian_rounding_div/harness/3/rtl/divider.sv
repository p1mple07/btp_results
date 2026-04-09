module divider
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

    // Assign the top-level outputs
    assign quotient  = quotient_reg;
    assign remainder = remainder_reg;
    assign valid     = valid_reg;

    // Initialize registers
    always @posedge clock) begin
        if (rst_n) begin
            state_reg = IDLE;
            quotient_reg = 0;
            remainder_reg = 0;
            aq_reg = 0;
            m_reg = divisor;
            n_reg = WIDTH-1;
            valid_reg = 0;
        end else if (start) begin
            if (state_reg == IDLE) begin
                state_reg = BUSY;
                // Initialize AQ with Q = dividend and A = 0
                aq_reg = [0][dividend];
                m_reg = divisor;
                n_reg = WIDTH-1;
                valid_reg = 0;
            end else if (n_reg > 0) begin
                // Algorithm steps
                aq_next = aq_reg << 1;
                sign_bit = (aq_reg >> (WIDTH + 1 - 1)) & 1;
                if (sign_bit) begin
                    aq_next = aq_next + m_reg;
                else
                    aq_next = aq_next - m_reg;
                end
                quotient_next = (sign_bit ? (1 << 0) : 0) | (quotient_reg << 1);
                n_next = n_reg - 1;
                aq_reg = aq_next;
                n_reg = n_next;
                m_next = m_reg;
                state_next = BUSY;
            end else if (n_reg == 0) begin
                // Final adjustment
                if (sign_bit) begin
                    aq_next = aq_reg + m_reg;
                else
                    aq_next = aq_reg;
                end
                quotient_next = quotient_reg;
                n_next = 0;
                aq_reg = aq_next;
                n_reg = n_next;
                m_next = m_reg;
                state_next = DONE;
            end
        end
    end

    // Output valid signal
    always @posedge clock) begin
        if (state_reg == DONE) begin
            valid_next = 1;
        else if (state_reg == IDLE) begin
            valid_next = 0;
        else
            valid_next = valid_reg;
        end
    end

    wire valid_next;
endmodule