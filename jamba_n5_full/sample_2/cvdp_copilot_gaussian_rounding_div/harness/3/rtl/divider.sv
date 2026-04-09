module divider (#(W=32));
    parameter WIDTH = W;

    localparam AW = WIDTH + 1;
    localparam BIT = 1;

    reg [1:0] state_reg, state_next;
    reg [AW-1:0] aq_reg, aq_next;
    reg [AW-1:0] m_reg, m_next;
    reg [WIDTH-1:0] n_reg, n_next;
    reg [WIDTH-1:0] quotient_reg, quotient_next;
    reg [WIDTH-1:0] remainder_reg, remainder_next;
    reg valid_reg, valid_next;

    // === State machine transitions ===
    always @(posedge clk or posedge rst_n) begin
        if (!rst_n) begin
            state_reg <= IDLE;
            aq_reg <= 0;
            aq_next <= 0;
            m_reg <= 0;
            m_next <= 0;
            n_reg <= 0;
            n_next <= 0;
            quotient_reg <= 0;
            quotient_next <= 0;
            remainder_reg <= 0;
            remainder_next <= 0;
            valid_reg <= 0;
            valid_next <= 0;
        end else begin
            case (state_reg)
            IDLE: begin
                if (start) begin
                    state_next <= BUSY;
                end else begin
                    state_next <= IDLE;
                end
            end
            BUSY: begin
                // Load dividend and divisor
                aq_reg = dividend;
                m_reg = divisor;

                // Determine sign bit of A
                q_sign = aq_reg[AW-1];

                // Shift A left by 1
                aq_next = {aq_reg[AW-1], aq_reg[AW-2:0]};

                // Apply addition or subtraction
                if (q_sign)
                    aq_next = aq_next + m_reg;
                else
                    aq_next = aq_next - m_reg;

                // Decrement N
                n_reg <= n_next;

                // Check if we reached zero
                if (n_reg == 0)
                    state_next <= DONE;
                else
                    state_next <= BUSY;
            end
            DONE: begin
                // Finalise the result
                valid_next = 1'b1;
                quotient_next = aq_reg;
                remainder_next = aq_reg;
                state_next <= IDLE;
            end
            endcase
        end
    end

    // === Output assignment ===
    assign quotient = quotient_reg;
    assign remainder = remainder_reg;
    assign valid = valid_reg;

endmodule
