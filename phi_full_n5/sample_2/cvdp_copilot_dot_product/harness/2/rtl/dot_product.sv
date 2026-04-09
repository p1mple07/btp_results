always @(posedge clk_in) begin
    if (reset_in) begin
        state <= IDLE;
        dot_product_out <= 32'h00000000;
        dot_product_valid_out <= 0;
    end else if (start_in && state == IDLE) begin
        state <= COMPUTE;
    end else if (state == COMPUTE) begin
        case (vector_a_valid_in)
            1'b1: begin
                dot_product_out <= dot_product_out + (vector_a_in << 8) * (vector_b_in >> (7 - dot_length_in));
                if (vector_b_valid_in)
                    state <= OUTPUT;
                else
                    state <= COMPUTE;
            end
        endcase
    end else if (state == OUTPUT) begin
        dot_product_valid_out <= 1;
        state <= IDLE;
    end
end
