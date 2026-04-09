always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk_div2 <= 1'b0;
        current_state <= IDLE;
        ATTN_CLK      <= 1'b0;
        ATTN_DATA     <= 1'b0;
        ATTN_LE       <= 1'b0;
        shift_reg     <= 5'b00000;
        bit_count     <= 3'd0;
        old_data      <= 5'b00000;
    end else begin
        case (current_state)
            IDLE: begin
                if (data != old_data) begin
                    shift_reg <= data;
                    next_state <= LOAD;
                end else begin
                    ATTN_CLK <= 1'b0;
                    ATTN_DATA <= 1'b0;
                    ATTN_LE <= 1'b0;
                    current_state <= IDLE;
                end
            end
            LOAD: begin
                bit_count <= 3'd5;
                next_state <= SHIFT;
            end
            SHIFT: begin
                if (bit_count == 3'd5) begin
                    ATTN_DATA <= shift_reg[bit_count - 1];
                    bit_count <= 3'd0;
                    next_state <= LATCH;
                end else begin
                    ATTN_CLK <= ~ATTN_CLK;
                    next_state <= SHIFT;
                end
            end
            LATCH: begin
                ATTN_LE <= 1'b1;
                next_state <= IDLE;
            end
        endcase
    end
end
