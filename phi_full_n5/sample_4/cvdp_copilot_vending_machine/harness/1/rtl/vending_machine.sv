module vending_machine (
    input clk,
    input rst,
    input item_button,
    input [2:0] item_selected,
    input [3:0] coin_input,
    input cancel,
    output reg dispense_item,
    output reg return_change,
    output reg [4:0] item_price,
    output reg [4:0] change_amount,
    output reg [2:0] dispense_item_id,
    output reg error,
    output reg return_money
);

    // State declaration
    typedef enum logic [1:0] {IDLE, ITEM_SELECTION, PAYMENT_VALIDATION, DISPENSING_ITEM, RETURN_CHANGE, RETURN_MONEY} state_t;
    reg [1:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // State transition logic
    always @* begin
        case (current_state)
            IDLE:
                if (item_button) begin
                    next_state = ITEM_SELECTION;
                end
                else begin
                    next_state = IDLE;
                end

            ITEM_SELECTION:
                if (item_selected >= 3'b001 && item_selected <= 3'b100) begin
                    next_state = PAYMENT_VALIDATION;
                end
                else begin
                    error <= 1'b1;
                    next_state = RETURN_MONEY;
                end

            PAYMENT_VALIDATION:
                if (cancel) begin
                    error <= 1'b1;
                    next_state = RETURN_MONEY;
                end
                else begin
                    // Accumulate coins
                    if (coin_input == 4'b0000 || coin_input == 4'b0001 || coin_input == 4'b0010 || coin_input == 4'b0100) begin
                        // Assuming we have a register to accumulate coins
                        // coins_accumulated <= coins_accumulated + coin_input;

                        if (coins_accumulated >= item_price) begin
                            next_state = DISPENSING_ITEM;
                        end
                        else begin
                            error <= 1'b1;
                            next_state = RETURN_MONEY;
                        end
                    end
                    else begin
                        error <= 1'b1;
                        next_state = RETURN_MONEY;
                    end
                end

            DISPENSING_ITEM:
                if (coins_accumulated > item_price) begin
                    dispense_item <= 1'b1;
                    next_state = RETURN_CHANGE;
                end
                else begin
                    next_state = IDLE;
                end

            RETURN_CHANGE:
                if (coins_accumulated > change_amount) begin
                    change_amount <= coins_accumulated - change_amount;
                    next_state = IDLE;
                    return_change <= 1'b1;
                end
                else begin
                    next_state = IDLE;
                end

            RETURN_MONEY:
                if (coins_accumulated > 0) begin
                    return_money <= 1'b1;
                    next_state = IDLE;
                end
                else begin
                    next_state = IDLE;
                end

            default:
                next_state = IDLE;
        end
    end

    // Output logic
    always @(posedge clk) begin
        if (error)
            dispense_item <= 1'b0;
        else
            dispense_item <= 1'b0;

        if (return_money)
            return_change <= 1'b0;
        else
            return_change <= 1'b0;

        item_price = item_price; // Assuming item_price is set in ITEM_SELECTION state
        change_amount = change_amount; // Assuming change_amount is calculated in RETURN_CHANGE state
        dispense_item_id = dispense_item_id; // Assuming dispense_item_id is set in DISPENSING_ITEM state
        error = error;
    end

endmodule
