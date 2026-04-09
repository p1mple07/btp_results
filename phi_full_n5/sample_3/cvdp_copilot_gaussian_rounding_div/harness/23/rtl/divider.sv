
// Optimized divider module with area reduction
module divider #(
    parameter WIDTH = 32
) (
    input  wire                  clk,
    input  wire                  rst_n,      // Active-low asynchronous reset
    input  wire                  start,      // Start signal for new operation
    input  wire [WIDTH-1 : 0]    dividend,   // Dividend (numerator)
    input  wire [WIDTH-1 : 0]    divisor,    // Divisor (denominator)
    output wire [WIDTH-1 : 0]    quotient,   // Result of the division
    output wire [WIDTH-1 : 0]    remainder,  // Remainder after division
    output wire                  valid       // Indicates output is valid
);

    // One extra bit for A
    localparam AW = WIDTH + 1;
    // Simplified FSM with fewer state transitions and registers
    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state_reg, state_next;

    // Directly initialize aq_reg with dividend and divisor
    reg [AW+WIDTH-1 : 0] aq_reg;
    reg [AW-1 : 0]       m_reg;
    reg [$clog2(WIDTH)-1:0] n_reg;

    // Directly initialize quotient_reg with the final quotient
    reg [WIDTH-1:0] quotient_reg;
    reg [WIDTH-1:0] remainder_reg;
    reg valid_reg;

    // Assign the top-level outputs
    assign quotient = quotient_reg;
    assign remainder = remainder_reg;
    assign valid = valid_reg;

    // Sequential logic with fewer registers and state transitions
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg <= IDLE;
            aq_reg <= {WIDTH{1'b0}, dividend};
            m_reg <= divisor;
            n_reg <= WIDTH;
            quotient_reg <= 0;
            remainder_reg <= 0;
            valid_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            aq_reg <= aq_next;
            m_reg <= m_next;
            n_reg <= n_next;
            quotient_reg <= quotient_next;
            remainder_reg <= remainder_next;
            valid_reg <= valid_next;
        end
    end

    // Combinational logic simplified
    always @* begin
        case (state_reg)
        IDLE: begin
            valid_next = 1'b0;
            if (start) begin
                aq_reg = {WIDTH{1'b0}, dividend};
                m_reg = divisor;
                n_reg = WIDTH;
                state_next = BUSY;
            end
        end

        BUSY: begin
            aq_next = aq_reg << 1;
            if (aq_reg[AW+WIDTH-1] == 1'b1) begin
                aq_next[AW+WIDTH-1 : WIDTH] = aq_next[AW+WIDTH-1 : WIDTH] + m_reg;
            end
            aq_next[0] = aq_reg[0] ^ m_reg[0]; // XOR for sign bit handling
            n_next = n_reg - 1;
            if (n_next == 0) begin
                state_next = DONE;
            end
        end

        DONE: begin
            if (aq_reg[AW+WIDTH-1] == 1'b1) begin
                aq_next = aq_reg;
                aq_next[AW+WIDTH-1 : WIDTH] = aq_reg[AW+WIDTH-1 : WIDTH] + m_reg;
            end
            quotient_next = aq_next[WIDTH-1 : 0];
            remainder_next = aq_next[2*WIDTH-1 : WIDTH];
            valid_next = 1'b1;
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
