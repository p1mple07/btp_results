// State declarations
state state_state;
reg [4:0] item_price;
reg [4:0] change_amount;
reg [3:0] dispense_item_id;
reg error;
reg return_money;

// State transitions and logic
always @(posedge clk) begin
    case (state_state)
        IDLE: 
            if (item_button) begin
                state_state = ITEM_SELECTION;
                item_price = 0;
                change_amount = 0;
                dispense_item_id = 0;
            end
            else if (error) begin
                state_state = RETURN_MONEY;
                return_money = 1;
                error = 0;
            end
        ITEM_SELECTION: 
            if (item_selected) begin
                dispense_item_id = item_selected;
                item_price = item_price_table[item_selected];
                state_state = PAYMENT_VALIDATION;
            end
            else if (cancel) begin
                state_state = RETURN_MONEY;
                error = 1;
                return_money = 1;
            end
        PAYMENT_VALIDATION: 
            if (coin_input & 0b1111) begin
                coins_accumulated +== 1;
                if (coins_accumulated >= item_price) begin
                    state_state = DISPENSING_ITEM;
                    coins_accumulated = 0;
                end else begin
                    state_state = RETURN_MONEY;
                    error = 1;
                    return_money = 1;
                end
            end
        DISPENSING_ITEM: 
            dispense_item = 1;
            if (coins_accumulated > item_price) begin
                change_amount = coins_accumulated - item_price;
                state_state = RETURNCHANGE;
            else begin
                state_state = IDLE;
            end
        RETURNCHANGE: 
            return_change = 1;
            state_state = IDLE;
        RETURN_MONEY: 
            return_money = 0;
            state_state = IDLE;
    endcase
end