always @(posedge clk or posedge rst) begin
    if (rst) begin
        done <= 0;
        result <= 0;
        accumulator <= 0;
        addition_counter <= 0;
        multiplicand <= 0;
        booth_bits <= 0;
        for (i = 0; i < WIDTH/2; i = i + 1) begin
            encoding_bits[i] <= 0;
            partial_products[i] <= 0;
        end
    end else begin
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = ENCODE;
                end else begin
                    next_state = IDLE;
                end
            end

            ENCODE: begin
                next_state = PARTIAL;
                for (i = 0; i < WIDTH/2; i = i + 1) begin
                    encoding_bits[i] <= booth_bits[2*i +: 3];
                end
            end

            PARTIAL: begin
                next_state = ADDITION;
                for (i = 0; i < WIDTH/2; i = i + 1) begin
                    case (encoding_bits[i])
                        3'b001: partial_products[i] <= (multiplicand << (2 * i));
                        3'b010: partial_products[i] <= (multiplicand << (2 * i));
                        3'b011: partial_products[i] <= (multiplicand << (2 * i)) >>> 1; // Correct shift for doubling
                        3'b100: partial_products[i] <= -(multiplicand << (2 * i)) >>> 1; // Correct shift for doubling and negation
                        3'b101: partial_products[i] <= -(multiplicand << (2 * i));
                        default: partial_products[i] <= 0;
                    endcase
                end
            end

            ADDITION: begin
                next_state = DONE;
                for (i = 0; i < WIDTH/2; i = i + 1) begin
                    accumulator <= accumulator + partial_products[i];
                    addition_counter <= addition_counter + 1; // Increment addition_counter
                end
            end

            DONE: begin
                if (!start) begin
                    next_state = IDLE;
                end else begin
                    next_state = DONE;
                end
            end

            default: next_state = IDLE;
        endcase
    end
end
