`timescale 1ns/1ps
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

    // State register: 1 bit
    reg state_reg;

    // Combinational logic merged
    always @* begin
        case (state_reg)
        IDLE: begin
            if (start) begin
                state_reg <= BUSY;
                quotient_next = 1'b0;
                remainder_next = dividend;
            end
            else begin
                state_reg <= IDLE;
                valid_next = 1'b0;
            end
        end
        BUSY: begin
            aq_next = aq_reg << 1;
            if (aq_reg[WIDTH-1] == 1'b1) begin
                aq_next[WIDTH-1 : WIDTH] = aq_next[WIDTH-1 : WIDTH] + divisor;
            end else begin
                aq_next[WIDTH-1 : WIDTH] = aq_next[WIDTH-1 : WIDTH] - divisor;
            end
            quotient_next = (aq_reg[WIDTH-1] == 1'b1) ? 1'b0 : 1'b1;
            n_next = n_reg - 1;
            if (n_next == 0) begin
                state_reg <= DONE;
                valid_next = 1'b1;
                quotient_next = aq_reg[WIDTH-1 : 0];
                remainder_next = aq_reg[2*WIDTH-1 : WIDTH];
            end
        end
        DONE: begin
            if (aq_reg[WIDTH-1] == 1'b1) begin
                aq_next = aq_reg;
                aq_next[WIDTH-1 : WIDTH] = aq_reg[WIDTH-1 : WIDTH] + divisor;
            end
            quotient_next = aq_reg[WIDTH-1 : 0];
            remainder_next = aq_reg[2*WIDTH-1 : WIDTH];
            valid_next = 1'b1;
            state_reg <= IDLE;
        end
        default: begin
            state_reg <= IDLE;
        end
        endcase
    end

    // Register updates
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
            state_reg     <= state_reg;
            aq_reg        <= aq_reg;
            m_reg         <= m_reg;
            n_reg         <= n_reg;
            quotient_reg  <= quotient_reg;
            remainder_reg <= remainder_reg;
            valid_reg     <= valid_reg;
        end
    end

endmodule
