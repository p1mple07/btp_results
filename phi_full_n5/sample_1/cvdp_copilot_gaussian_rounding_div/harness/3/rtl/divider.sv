// Insert code for non-restoring division
always @(posedge clk) begin
    if (rst_n) begin
        state_reg <= IDLE;
        aq_reg <= {dividend, 1'b0};
        m_reg <= divisor;
        n_reg <= WIDTH;
        quotient_reg <= 0;
        remainder_reg <= 0;
        valid_reg <= 0;
    end else begin
        state_next = state_reg;

        case (state_reg)
            IDLE: begin
                if (start) begin
                    state_next = BUSY;
                    aq_next = {aq_reg[WIDTH-1:0], dividend};
                    m_next = divisor;
                    n_next = n_reg;
                end
                // No action needed for IDLE state after start signal
            end
            BUSY: begin
                // Check sign bit of A
                if (aq_reg[0]) begin
                    aq_next = {aq_reg[WIDTH-1:1], (aq_reg[0] ^ m_reg[0])};
                    m_next = m_reg + {1'b1, m_reg[WIDTH-1:1]};
                end else begin
                    aq_next = {aq_reg[WIDTH-1:1], (aq_reg[0] ^ m_reg[0])};
                    m_next = m_reg - {1'b1, m_reg[WIDTH-1:1]};
                end
                n_next = n_reg - 1;
                // Update Q[0]
                quotient_next[0] = (~aq_reg[0]) & aq_reg[1];
                // Update A
                if (aq_reg[0]) begin
                    aq_next = aq_next + m_next;
                end else begin
                    aq_next = aq_next - m_next;
                end
                // Decrement N
                if (n_reg == 0) begin
                    state_next = DONE;
                end else begin
                    state_next = BUSY;
                end
            end
            DONE: begin
                valid_next = 1;
                state_next = IDLE;
            end
        endcase
        state_reg <= state_next;
        aq_reg <= aq_next;
        m_reg <= m_next;
        n_reg <= n_next;
        quotient_reg <= quotient_next;
        remainder_reg <= aq_reg; // Remainder is the updated A register
        valid_reg <= valid_next;
    end
end
