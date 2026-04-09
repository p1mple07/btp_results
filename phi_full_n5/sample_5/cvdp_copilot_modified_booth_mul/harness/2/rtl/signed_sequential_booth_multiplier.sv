    // PARTIAL: Generate partial products based on Booth encoding
    begin
        case (encoding_bits[i])
            3'b001: partial_products[i] <= (multiplicand << (2 * i));
            3'b010: partial_products[i] <= ((multiplicand << 1) << (2 * i));
            3'b011: partial_products[i] <= ((multiplicand << 1) << (2 * i));
            3'b100: partial_products[i] <= (multiplicand << 1) << (2 * i);
            3'b101: partial_products[i] <= (-(multiplicand << 1)) << (2 * i);
            3'b110: partial_products[i] <= -(multiplicand << 1) << (2 * i);
            default: partial_products[i] <= 0;
        endcase
    end

    // ADDITION: Accumulate partial products
    begin
        accumulator <= 0;
        for (i = 0; i < WIDTH/2; i = i + 1) begin
            accumulator <= accumulator + partial_products[i];  
        end
    end
