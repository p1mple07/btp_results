// Complete logic for FSM
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
                if (!(old_data == data)) begin
                    current_state <= LOAD;
                end else begin
                    current_state <= IDLE;
                end
            end
            LOAD: begin
                shift_reg <= data;
                bit_count <= 5'b00001;
                current_state <= SHIFT;
            end
            SHIFT: begin
                ATTN_DATA <= shift_reg[bit_count];
                clk_div2 <= ~clk_div2;
                if (bit_count == 5'b00010) begin
                    bit_count <= 3'd0;
                    current_state <= LATCH;
                end else begin
                    bit_count <= bit_count + 1'b1;
                end
            end
            LATCH: begin
                ATTN_LE <= 1'b1;
                if (bit_count == 5'b00010) begin
                    bit_count <= 3'd0;
                    current_state <= IDLE;
                end
            end
        endcase
    end
end
