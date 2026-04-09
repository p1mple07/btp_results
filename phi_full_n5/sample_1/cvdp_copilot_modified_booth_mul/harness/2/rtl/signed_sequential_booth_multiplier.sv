ADDITION: begin
    accumulator <= 0;
    for (i = 0; i < WIDTH/2; i = i + 1) begin
        accumulator <= accumulator + partial_products[i];  
    end
end
