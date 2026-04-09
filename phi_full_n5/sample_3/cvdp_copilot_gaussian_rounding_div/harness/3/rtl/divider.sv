// Insert code here for non-restoring division

always @(posedge clk) begin
    if (rst_n) begin
        state_reg <= IDLE;
        aq_reg <= {dividend, dividend};
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
                    aq_reg <= {dividend, dividend};
                    m_reg <= divisor;
                    n_reg <= WIDTH;
                    quotient_reg <= 0;
                    remainder_reg <= dividend;
                    valid_reg <= 0;
                end
            end
            BUSY: begin
                if (n_reg > 0) begin
                    // Perform non-restoring division steps
                    aq_next <= {aq_reg[WIDTH-1], aq_reg[WIDTH-2]};
                    remainder_next <= aq_reg[WIDTH-1] ^ m_reg[WIDTH-1];

                    if (aq_reg[WIDTH-1] == 1'b0) begin
                        remainder_next <= remainder_reg + m_reg;
                    end else begin
                        remainder_next <= remainder_reg - m_reg;
                    end

                    aq_reg <= aq_next;
                    remainder_reg <= remainder_next;
                    n_reg <= n_reg - 1;

                    if (n_reg == 0) begin
                        state_reg <= DONE;
                    end
                end
            end
            DONE: begin
                if (start) begin
                    state_reg <= IDLE;
                    valid_reg <= 1;
                end
            end
        endcase
    end
end

// Assign the next state and output registers
assign state_next = state_reg;
assign aq_next = aq_reg;
assign m_next = m_reg;
assign n_next = n_reg;
assign quotient_next = quotient_reg;
assign remainder_next = remainder_reg;
assign valid_next = valid_reg;
