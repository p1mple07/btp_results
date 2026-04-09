always @(posedge clk_in) begin
    if (reset_in) begin
        state <= IDLE;
        dot_product_out <= 32'h00000000;
        dot_product_valid_out <= 0;
    end else if (start_in) begin
        state <= IDLE;
    end else if (state == IDLE) begin
        if (vector_a_valid_in && vector_b_valid_in) begin
            state <= COMPUTE;
        end else begin
            state <= IDLE;
        end
    end else if (state == COMPUTE) begin
        dot_product_out <= (vector_a_in << 8) | (vector_b_in >> 8);
        for (int i = 0; i < dot_length_in; i++) begin
            if (vector_a_valid_in && vector_b_valid_in) begin
                dot_product_out = dot_product_out << 1;
                dot_product_out = dot_product_out | (vector_a_in * vector_b_in) >> (8 - i);
            end else begin
                state <= IDLE;
                break;
            end
        end
        state <= OUTPUT;
    end else if (state == OUTPUT) begin
        dot_product_valid_out <= 1;
    end
end
