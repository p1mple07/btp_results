// State variables
reg current_state = IDLE;
reg error_state = IDLE;
reg coins_accumulated = 0;
reg dispense_item = 0;
reg dispense_item_id = 0;
reg item_price = 0;
reg change_amount = 0;
reg return_money = 0;

// State transition table
always @(posedge clk) begin
    case(current_state)
        IDLE:
            if (rst) begin
                current_state = IDLE;
                error_state = IDLE;
                coins_accumulated = 0;
                dispense_item = 0;
                dispense_item_id = 0;
                item_price = 0;
                change_amount = 0;
                return_money = 0;
            end else if (item_button) begin
                current_state = ITEM_SELECTION;
            end else if (cancel) begin
                current_state = IDLE;
            end else if (error_state) begin
                current_state = error_state;
            end
            // Reset if rst is high
            if (rst) begin
                current_state = IDLE;
                error_state = IDLE;
                coins_accumulated = 0;
                dispense_item = 0;
                dispense_item_id = 0;
                item_price = 0;
                change_amount = 0;
                return_money = 0;
            end
        ITEM_SELECTION:
            if (item_selected) begin
                // Set item price based on item_selected
                case (item_selected)
                    3'b001: item_price = 1;
                    3'b010: item_price = 2;
                    3'b011: item_price = 5;
                    default: item_price = 10;
                endcase
                current_state = PAYMENT_VALIDATION;
            else begin
                // Invalid item selection
                error_state = IDLE;
                return_money = 1;
                current_state = RETURN_MONEY;
            end
        PAYMENT_VALIDATION:
            if (coin_input) begin
                // Validate coin input
                case (coin_input)
                    4'b0001: begin
                        coins_accumulated +== 1;
                        if (coins_accumulated >= item_price) begin
                            // Sufficient coins
                            current_state = DISPENSING_ITEM;
                        else begin
                            // Not enough coins
                            error_state = IDLE;
                            dispense_item = 0;
                            dispense_item_id = 0;
                            item_price = 0;
                            change_amount = 0;
                            return_money = 1;
                            current_state = RETURN_MONEY;
                        end
                    end
                    4'b0010: begin
                        coins_accumulated +== 2;
                        if (coins_accumulated >= item_price) begin
                            // Sufficient coins
                            current_state = DISPENSING_ITEM;
                        else begin
                            // Not enough coins
                            error_state = IDLE;
                            dispense_item = 0;
                            dispense_item_id = 0;
                            item_price = 0;
                            change_amount = 0;
                            return_money = 1;
                            current_state = RETURN_MONEY;
                        end
                    end
                    4'b0011: begin
                        coins_accumulated +== 5;
                        if (coins_accumulated >= item_price) begin
                            // Sufficient coins
                            current_state = DISPENSING_ITEM;
                        else begin
                            // Not enough coins
                            error_state = IDLE;
                            dispense_item = 0;
                            dispense_item_id = 0;
                            item_price = 0;
                            change_amount = 0;
                            return_money = 1;
                            current_state = RETURN_MONEY;
                        end
                    end
                    4'b0100: begin
                        coins_accumulated +== 10;
                        if (coins_accumulated >= item_price) begin
                            // Sufficient coins
                            current_state = DISPENSING_ITEM;
                        else begin
                            // Not enough coins
                            error_state = IDLE;
                            dispense_item = 0;
                            dispense_item_id = 0;
                            item_price = 0;
                            change_amount = 0;
                            return_money = 1;
                            current_state = RETURN_MONEY;
                        end
                    end
                end
            end
        DISPENSING_ITEM:
            if (cancel) begin
                error_state = IDLE;
                return_money = 1;
                current_state = RETURN_MONEY;
            else if (coins_accumulated > item_price) begin
                // Calculate change
                change_amount = coins_accumulated - item_price;
                return_money = 0;
                current_state = RETURNCHANGE;
            else begin
                // No change needed
                dispense_item = 1;
                dispense_item_id = item_selected;
                item_price = item_price;
                current_state = IDLE;
            end
        RETURNCHANGE:
            return_money = 1;
            current_state = RETURN_MONEY;
        RETURN_MONEY:
            return_money = 0;
            current_state = IDLE;
    endcase
end