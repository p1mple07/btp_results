always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        state_reg <= IDLE;
        aq_reg <= {dividend, dividend[0]};
        m_reg <= divisor;
        n_reg <= WIDTH;
        quotient_reg <= 0;
        remainder_reg <= dividend;
        valid_reg <= 0;
    end else begin
        case (state_reg)
            IDLE: begin
                if (start) begin
                    state_reg <= BUSY;
                    aq_reg <= {dividend, dividend[0]};
                    m_reg <= divisor;
                    n_reg <= WIDTH;
                    quotient_reg <= 0;
                    remainder_reg <= dividend;
                    valid_reg <= 0;
                end
                else begin
                    valid_reg <= 0;
                end
            end
            BUSY: begin
                if (n_reg == 0) begin
                    state_reg <= DONE;
                    valid_reg <= 1;
                end else begin
                    if (aq_reg[n_reg-1] == '1') begin
                        aq_reg <= {aq_reg[n_reg-1], aq_reg[n_reg-2]};
                        remainder_reg <= remainder_reg + m_reg;
                    end else begin
                        aq_reg <= {aq_reg[n_reg-1], aq_reg[n_reg-2]-m_reg};
                    end
                    quotient_reg <= quotient_reg + (aq_reg[n_reg-1] == '1' ? 1 : 0);
                    n_reg <= n_reg - 1;
                end
            end
            DONE: begin
                if (start) begin
                    state_reg <= IDLE;
                end else begin
                    valid_reg <= 0;
                end
            end
        endcase
    end
end
