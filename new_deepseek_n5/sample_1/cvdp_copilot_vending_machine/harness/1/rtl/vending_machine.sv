// State declarations
enum state_t state = state.IDLE;
enum state_t next_state;

// State transitions
always next_state begin
    case (state, item_button, cancel)
        state.IDLE & !item_button & !cancel => next_state = state.IDLE;
        state.IDLE & item_button & !cancel => next_state = state.ITEM_SELECTION;
        state.IDLE & item_button & cancel => next_state = state.RETURN_MONEY;
        state.ITEM_SELECTION & !item_selected => next_state = state.IDLE;
        state.ITEM_SELECTION & item_selected & !cancel => next_state = state.PAYMENT_VALIDATION;
        state.ITEM_SELECTION & item_selected & cancel => next_state = state.RETURN_MONEY;
        state.PAYMENT_VALIDATION & !coin_input => next_state = state.PAYMENT_VALIDATION;
        state.PAYMENT_VALIDATION & coin_input => next_state = state.PAYMENT_VALIDATION;
        state.PAYMENT_VALIDATION & (item_price > coins_accumulated) => next_state = state.PAYMENT_VALIDATION;
        state.PAYMENT_VALIDATION & (item_price <= coins_accumulated) => next_state = state.DISPENSING_ITEM;
        state.PAYMENT_VALIDATION & cancel => next_state = state.RETURN_MONEY;
        state.PAYMENT_VALIDATION & error => next_state = state.RETURN_MONEY;
        state.DISPENSING_ITEM & !dispense_item => next_state = state.DISPENSING_ITEM;
        state.DISPENSING_ITEM & dispense_item => next_state = state.RETURNCHANGE;
        state.RETURNCHANGE & !return_change => next_state = state.RETURNCHANGE;
        state.RETURNCHANGE & return_change => next_state = state.IDLE;
        state.RETURN_MONEY & !return_money => next_state = state.RETURN_MONEY;
        state.RETURN_MONEY & return_money => next_state = state.IDLE;
    endcase
end

// State machine transitions
always @posedge clock begin
    if (rst) 
        state = state.IDLE;
        next_state = state.IDLE;
    else 
        next_state = state.next_state;
    end
end

// Item selection validation
always @posedge clock begin
    if (item_button & !item_selected) 
        state = state.IDLE;
        next_state = state.IDLE;
    else 
        state = state.ITEM_SELECTION;
        next_state = state.ITEM_SELECTION;
    end
end

// Coin validation
always @posedge clock begin
    if (coin_input & !valid_coin) 
        state = state.IDLE;
        next_state = state.IDLE;
    else 
        state = state.PAYMENT_VALIDATION;
        next_state = state.PAYMENT_VALIDATION;
    end
end

// Change calculation
always @posedge clock begin
    if (change_amount > 0) 
        state = state.RETURNCHANGE;
        next_state = state.RETURNCHANGE;
    else 
        state = state.IDLE;
        next_state = state.IDLE;
    end
end

// Error handling
always @posedge clock begin
    if (error) 
        state = state.RETURN_MONEY;
        next_state = state.RETURN_MONEY;
    else 
        state = state.IDLE;
        next_state = state.IDLE;
    end
end

// Output assignments
always @posedge clock begin
    if (dispense_item) 
        dispense_item = 1;
        dispense_item.next_state = state.DISPENSING_ITEM;
    else 
        dispense_item = 0;
    end
    if (return_change) 
        return_change = 1;
        return_change.next_state = state.RETURNCHANGE;
    else 
        return_change = 0;
    end
    if (error) 
        error = 1;
        error.next_state = state.RETURN_MONEY;
    else 
        error = 0;
    end
    if (return_money) 
        return_money = 1;
        return_money.next_state = state.IDLE;
    else 
        return_money = 0;
    end
end

// Initial state assignments
state = state.IDLE;
next_state = state.IDLE;