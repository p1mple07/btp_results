// Insert code for non-restoring division algorithm
always @(posedge clk) begin
    if (rst_n) begin
        state_reg <= IDLE;
        aq_reg <= {1'b0, dividend, 1'b0};
        m_reg <= divisor;
        n_reg <= WIDTH;
        quotient_reg <= 0;
        remainder_reg <= 0;
        valid_reg <= 0;
    end else begin
        case (state_reg)
            IDLE: begin
                if (start) begin
                    state_reg <= BUSY;
                    aq_reg <= {1'b0, dividend, 1'b0};
                    m_reg <= divisor;
                    n_reg <= WIDTH;
                    quotient_reg <= 0;
                    remainder_reg <= 0;
                    valid_reg <= 0;
                end
                // No operation on other states
            end
            BUSY: begin
                if (n_reg > 0) begin
                    aq_next <= {aq_reg[WIDTH-1:0], aq_reg[0] - m_reg[0]};
                    n_next <= n_reg - 1;
                    quotient_next <= quotient_reg + (aq_reg[0] >= m_reg[0])';
                    remainder_next <= (aq_reg[0] >= m_reg[0]) * m_reg + aq_reg[1:WIDTH];
                    valid_next <= valid_reg;
                    state_next <= IDLE;
                end else begin
                    state_next <= DONE;
                end
            end
            DONE: begin
                state_reg <= DONE;
                valid_next <= 1;
            end
        endcase
        state_reg <= state_next;
        aq_reg <= aq_next;
        m_reg <= m_next;
        n_reg <= n_next;
        quotient_reg <= quotient_next;
        remainder_reg <= remainder_next;
        valid_reg <= valid_next;
    end
end
