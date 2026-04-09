`timescale 1ns/1ps
module divider #
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

    reg [1:0] state_reg, state_next;
    reg [AW-1 : 0]       aq_reg,   aq_next;
    reg [AW-1 : 0]       m_reg,    m_next;
    reg [$clog2(WIDTH)-1:0] n_reg, n_next;

    reg [WIDTH-1:0]       quotient_reg, quotient_next;
    reg [WIDTH-1:0]       remainder_reg, remainder_next;
    reg valid_reg, valid_next;

    assign quotient        = quotient_reg;
    assign remainder       = remainder_reg;
    assign valid           = valid_reg;

    // Sequential logic
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

    // Combinational logic
    always @* begin
        case (state_reg)
        //---------------------------------------------
        // IDLE: Wait for start
        //---------------------------------------------
        IDLE: begin
            valid_next = 1'b0;
            if (start) begin
                aq_next   = { {AW{1'b0}}, dividend };
                m_next    = {1'b0, divisor};
                n_next    = WIDTH;
                quotient_next = quotient_reg;
                remainder_next = remainder_reg;
                valid_next = 1'b1;
            end
            else begin
                state_next = BUSY;
            end
        end

        //---------------------------------------------
        // BUSY: Perform the N iterations
        //---------------------------------------------
        BUSY: begin
            aq_next   = aq_reg << 1;
            if (aq_reg[AW+WIDTH-1] == 1'b1) begin
                aq_next[AW+WIDTH-1 : WIDTH] = aq_reg[AW+WIDTH-1 : WIDTH] + m_reg;
            end
            else begin
                aq_next[AW+WIDTH-1 : WIDTH] = aq_reg[AW+WIDTH-1 : WIDTH] - m_reg;
            end
            n_next   = n_reg - 1;
            if (n_next == 0) state_next = DONE;
        end

        //---------------------------------------------
        // DONE: Final correction + output
        //---------------------------------------------
        DONE: begin
            if (aq_reg[AW+WIDTH-1] == 1'b1) begin
                aq_next = aq_reg;
                aq_next[AW+WIDTH-1 : WIDTH] = aq_reg[AW+WIDTH-1 : WIDTH] + m_reg;
            end

            quotient_next  = aq_next[WIDTH-1 : 0];
            remainder_next = aq_next[2*WIDTH-1 : WIDTH];
            valid_next = 1'b1;

            if (!start) state_next = IDLE;
            else state_next = DONE;
        end

        default: state_next = IDLE;
        endcase
    end

endmodule
