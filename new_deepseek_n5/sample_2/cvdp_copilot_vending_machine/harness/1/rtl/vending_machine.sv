// State array
state [
    // IDLE
    idle,
    // ITEM_SELECTION
    item_selection,
    // PAYMENT_VALIDATION
    payment_validation,
    // DISPENSING_ITEM
    dispensing_item,
    // RETURN_CHANGE
    return_change,
    // RETURN_MONEY
    return_money
] fsm;

// State variables
reg idle_state = idle;
reg item_selection_state = item_selection;
reg payment_validation_state = payment_validation;
reg dispensing_item_state = dispensing_item;
reg return_change_state = return_change;
reg return_money_state = return_money;

// State transition table
always @* begin
    case (idle_state)
        item_button & !rst => idle_state = item_selection;
        default => idle_state = idle;
    endcase

    case (item_selection_state)
        item_selected & !rst => idle_state = payment_validation;
        cancel & !rst => idle_state = return_money;
        default => idle_state = idle;
    endcase

    case (payment_validation_state)
        coin_input & !rst => 
            if (item_price >= 4'b00001 & item_price <= 4'b00100) 
                if (coins_accumulated >= item_price) 
                    idle_state = dispensing_item;
                else 
                    error = 1;
                    idle_state = return_money;
            else 
                error = 1;
                idle_state = return_money;
        default => idle_state = idle;
    endcase

    case (dispensing_item_state)
        return_change & !rst => idle_state = return_change;
        dispense_item & !rst => idle_state = idle;
        default => idle_state = idle;
    endcase

    case (return_change_state)
        return_money & !rst => idle_state = return_money;
        default => idle_state = idle;
    endcase

    case (return_money_state)
        return_money & !rst => idle_state = idle;
        default => idle_state = idle;
    endcase
endsys