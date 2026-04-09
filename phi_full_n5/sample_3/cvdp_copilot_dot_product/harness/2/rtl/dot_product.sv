// Inside the dot_product module

always @(posedge clk_in) begin
    if (reset_in) begin
        dot_product_out <= 32'h00000000;
        dot_product_valid_out <= 0;
        state <= IDLE;
    end else if (state == IDLE && start_in) begin
        state <= COMPUTE;
    end else if (state == COMPUTE) begin
        case (state)
            IDLE: begin
                if (vector_a_valid_in && vector_b_valid_in) begin
                    for (int i = 0; i < dot_length_in; i++) begin
                        dot_product_out <= dot_product_out + (vector_a_in[i] * vector_b_in[i + 6]);
                    end
                    state <= OUTPUT;
                end
            end
            OUTPUT: begin
                dot_product_valid_out <= 1;
                state <= IDLE; // Reset state machine for next computation
            end
        endcase
    end
end
