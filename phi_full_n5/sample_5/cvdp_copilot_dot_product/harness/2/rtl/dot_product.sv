always @(posedge clk_in) begin
    if (reset_in) begin
        state <= IDLE;
        dot_product_out <= 32'h00000000;
        dot_product_valid_out <= 0;
    end else if (state == IDLE && start_in) begin
        state <= COMPUTE;
    end else if (state == COMPUTE) begin
        case (state)
            IDLE: begin
                if (vector_a_valid_in && vector_b_valid_in) begin
                    dot_product_out <= (vector_a_in * vector_b_in) << (dot_length_in - 1);
                    state <= OUTPUT;
                end else begin
                    state <= IDLE;
                end
            end
            OUTPUT: begin
                if (vector_a_valid_in && vector_b_valid_in) begin
                    dot_product_valid_out <= 1;
                end else begin
                    state <= IDLE;
                end
            end
        endcase
    end
end
