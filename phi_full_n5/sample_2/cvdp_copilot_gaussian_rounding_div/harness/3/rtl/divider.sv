// Insert code here for non-restoring division
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
            end
            BUSY: begin
                if (n_reg == 0) begin
                    state_reg <= DONE;
                end else begin
                    case (aq_reg[n_reg-1])
                        1'b1: begin
                            if (aq_reg[0]) begin
                                aq_reg <= aq_reg + m_reg;
                                m_reg <= m_reg << 1;
                                n_reg <= n_reg - 1;
                            end else begin
                                aq_reg <= aq_reg - m_reg;
                                m_reg <= m_reg << 1;
                                n_reg <= n_reg - 1;
                            end
                        end
                        1'b0: begin
                            aq_reg <= aq_reg << 1;
                            n_reg <= n_reg - 1;
                        end
                    end
                end
                state_next <= state_reg;
            end
            DONE: begin
                state_reg <= DONE;
                quotient_next <= quotient_reg;
                remainder_next <= remainder_reg;
                valid_next <= 1;
            end
        endcase
        state_reg <= state_next;
    end
end
