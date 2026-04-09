// Combinational logic optimizations
always @* begin
    // ... (Keep the initial state and next-state logic unchanged)

    // BUSY state optimized
    BUSY: begin
        // Perform the shift and addition/subtraction in one step
        aq_next = {aq_reg, m_reg} << 1;
        // Conditionally adjust sign bit
        aq_next[1:WIDTH] = (aq_reg[1:WIDTH] == 1'b1) ? aq_next[1:WIDTH] + m_reg : aq_next[1:WIDTH] - m_reg;
        // Set the LSB of the quotient
        quotient_next[0] = (aq_reg[1] == 1'b1) ? 1'b0 : 1'b1;
        // Decrement iteration count
        n_next = n_reg - 1;

        // Check if we are done
        if (n_next == 0) begin
            state_next = DONE;
        end
    end

    // DONE state with optimized final correction
    DONE: begin
        // Adjust sign bit for remainder
        if (aq_reg[1] == 1'b1) begin
            aq_next = aq_reg;
            aq_next[1:WIDTH] = aq_reg[1:WIDTH] + m_reg;
        end
        else begin
            aq_next = aq_reg;
            aq_next[1:WIDTH] = aq_reg[1:WIDTH] - m_reg;
        end

        // Extract quotient and remainder
        quotient_next = aq_next[WIDTH-1:0];
        remainder_next = aq_next[2*WIDTH-1:WIDTH];

        // Set validity
        valid_next = 1'b1;

        // Return to IDLE or DONE state based on start signal
        if (!start) begin
            state_next = IDLE;
        end else begin
            state_next = DONE;
        end
    end

    // ... (Keep the default case unchanged)
end
