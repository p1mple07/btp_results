ADDITION: begin
    accumulator <= 0;
    for (i = 0; i < WIDTH/2; i = i + 1) begin
        if (partial_products[i] != 0) begin
            accumulator <= accumulator + partial_products[i] << (2 * i);
        end
    end
end
