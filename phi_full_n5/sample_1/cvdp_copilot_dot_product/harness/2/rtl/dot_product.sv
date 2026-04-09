always @(posedge clk_in) begin
    if (reset_in) begin
        state <= IDLE;
        dot_product_out <= 32'h00000000;
        dot_product_valid_out <= 0;
    end else if (start_in) begin
        state <= IDLE;
    end else if (state == IDLE) begin
        if (vector_a_valid_in) begin
            state <= COMPUTE;
        end else begin
            state <= IDLE;
        end
    end else if (state == COMPUTE) begin
        if (vector_b_valid_in) begin
            dot_product_out <= (dot_product_out << 8) + (vector_a_in * vector_b_in);
            state <= (dot_length_in > 0) ? COMPUTE : OUTPUT;
        end else begin
            state <= IDLE;
        end
    end else if (state == OUTPUT) begin
        dot_product_valid_out <= 1;
        state <= IDLE;
    end
end
