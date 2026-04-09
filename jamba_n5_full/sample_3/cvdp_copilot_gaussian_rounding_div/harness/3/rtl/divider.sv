module divider #(
    parameter WIDTH = 32
) (
    input  wire                  clk,
    input  wire                  rst_n,      // Active-low asynchronous reset
    input  wire                  start,      // Start signal for new operation
    input  wire [WIDTH-1:0]    dividend,   // Dividend (numerator)
    input  wire [WIDTH-1:0]    divisor,    // Divisor (denominator)
    output wire [WIDTH-1:0]    quotient,   // Result of the division
    output wire [WIDTH-1:0]    remainder,  // Remainder after division
    output wire                  valid       // Indicates output is valid
);

    localparam AW = WIDTH + 1;
    localparam BIT = 1;
    localparam IDLE  = 2'b00;
    localparam BUSY  = 2'b01;
    localparam DONE  = 2'b10;

    reg [1:0] state, state_next;
    reg [WIDTH-1:0] aq, aq_next;
    reg [WIDTH-1:0] m_reg, m_next;
    reg [WIDTH-1:0] n_reg, n_next;
    reg [WIDTH-1:0] quotient_reg, quotient_next;
    reg [WIDTH-1:0] remainder_reg, remainder_next;
    reg valid_reg, valid_next;

    initial begin
        state     = IDLE;
        aq        = 0;
        aq_next   = 0;
        m_reg     = 0;
        m_next    = 0;
        n_reg     = 0;
        n_next    = 0;
        quotient_reg = 0;
        quotient_next = 0;
        remainder_reg = 0;
        remainder_next = 0;
        valid_reg  = 1'b0;
        valid_next = 1'b0;
    end

    always @(posedge clk or posedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            aq        = 0;
            aq_next   = 0;
            m_reg     = 0;
            m_next    = 0;
            n_reg     = 0;
            n_next    = 0;
            quotient_reg = 0;
            quotient_next = 0;
            remainder_reg = 0;
            remainder_next = 0;
            valid_reg  = 1'b0;
            valid_next = 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state     <= BUSY;
                    end
                end
                BUSY: begin
                    aq_next   = aq;
                    m_next    = m_reg;
                    n_next    = n_reg - 1;

                    // Extract the MSB for sign bit
                    bit_a = aq[AW-1];

                    if (bit_a == 1'b1) begin
                        // Subtract divisor
                        aq_next = aq << 1;
                        aq_next[AW-1] = aq_next[AW-1] + m_reg;
                    else begin
                        // Add 2's complement of divisor
                        aq_next = aq << 1;
                        aq_next[AW-1] = aq_next[AW-1] + m_reg;
                    end

                    quotient_next = aq_next[AW-1];
                    n_next = n_reg;
                    if (n_next == 0) state <= DONE;
                end
                DONE: begin
                    // Output is ready
                    valid_reg  = 1'b1;
                    valid_next  = 1'b1;
                end
            endcase
        end
    end

    assign quotient = quotient_reg;
    assign remainder = remainder_reg;
    assign valid = valid_reg;

endmodule
