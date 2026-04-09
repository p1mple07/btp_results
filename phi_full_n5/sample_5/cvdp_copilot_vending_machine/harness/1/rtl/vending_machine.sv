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
    typedef enum logic [1:0] {
        IDLE,
        ITEM_SELECTION,
        PAYMENT_VALIDATION,
        DISPENSING_ITEM,
        RETURN_CHANGE,
        RETURN_MONEY
    } state_t;

    state_t state, next_state;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            dispense_item <= 0;
            return_change <= 0;
            item_price <= 0;
            change_amount <= 0;
            dispense_item_id <= 0;
            error <= 0;
            return_money <= 0;
        end else begin
            state <= next_state;
        end
    end

    // State transition process
    process (state, item_button, coin_input, cancel) begin
        case (state)
            IDLE:
                if (item_button) begin
                    next_state <= ITEM_SELECTION;
                end else begin
                    next_state <= IDLE;
                end
                break;

            ITEM_SELECTION:
                if (item_selected >= 3'b001 && item_selected <= 3'b100) begin
                    next_state <= PAYMENT_VALIDATION;
                end else begin
                    next_state <= IDLE;
                    error <= 1;
                end
                break;

            PAYMENT_VALIDATION:
                if (cancel) begin
                    next_state <= RETURN_MONEY;
                end else begin
                    if (coin_input == 1'b0 || coin_input == 1'b1 || coin_input == 1'b2 || coin_input == 1'b5 || coin_input == 1'b10) begin
                        coins_accumulated <= coins_accumulated + coin_input;
                        if (coins_accumulated >= item_price) begin
                            next_state <= DISPENSING_ITEM;
                        end else begin
                            next_state <= PAYMENT_VALIDATION;
                        end
                    end else begin
                        next_state <= PAYMENT_VALIDATION;
                        error <= 1;
                    end
                end
                break;

            DISPENSING_ITEM:
                if (coins_accumulated >= item_price) begin
                    dispense_item <= 1;
                    item_price <= 4'b0001; // Assuming the price of the item is 1 unit for simplicity
                    next_state <= RETURN_CHANGE;
                end else begin
                    next_state <= PAYMENT_VALIDATION;
                end
                break;

            RETURN_CHANGE:
                if (coins_accumulated > item_price) begin
                    change_amount <= coins_accumulated - item_price;
                    return_change <= 1;
                    next_state <= IDLE;
                end else begin
                    next_state <= IDLE;
                end
                break;

            RETURN_MONEY:
                if (coins_accumulated > 0) begin
                    return_money <= 1;
                    next_state <= IDLE;
                end else begin
                    next_state <= IDLE;
                end
                break;
        end
    end

    // Output logic
    always @(posedge clk) begin
        if (error) begin
            error <= 1;
            return_money <= 1;
        end else begin
            error <= 0;
            return_money <= 0;
        end
    end

endmodule
