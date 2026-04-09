module vending_machine #(parameter NUM_ITEMS = 4)
(
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

    state_t current_state, next_state;
    logic [3:0] coins_accumulated = 0;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            coins_accumulated <= 0;
            item_price <= 0;
            change_amount <= 0;
            dispense_item_id <= 0;
            error <= 0;
            return_money <= 0;
        end else if (item_button) begin
            current_state <= ITEM_SELECTION;
        end else if (current_state == IDLE) begin
            next_state = ITEM_SELECTION;
        end else if (current_state == ITEM_SELECTION) begin
            if (item_selected >= 3'b001 && item_selected <= 3'b100) begin
                next_state = PAYMENT_VALIDATION;
            end else begin
                error <= 1;
                next_state = RETURN_MONEY;
            end
        end else if (current_state == PAYMENT_VALIDATION) begin
            coins_accumulated <= coins_accumulated + coin_input;
            if (coins_accumulated >= item_price) begin
                next_state = DISPENSING_ITEM;
            end else begin
                error <= 1;
                next_state = RETURN_MONEY;
            end
        end else if (current_state == DISPENSING_ITEM) begin
            dispense_item <= 1;
            next_state = RETURN_CHANGE;
        end else if (current_state == RETURN_CHANGE) begin
            return_change <= 1;
            next_state = RETURN_MONEY;
        end else if (current_state == RETURN_MONEY) begin
            return_money <= 1;
            next_state = IDLE;
        end

        current_state <= next_state;
    end

    // Output logic
    always @(current_state) begin
        case (current_state)
            IDLE:
                item_price <= 0;
                dispense_item_id <= 0;
                change_amount <= 0;
                error <= 0;
                return_money <= 0;

            ITEM_SELECTION:
                item_price <= 5'b0; // Placeholder for actual item prices
                dispense_item_id <= item_selected;
                error <= 0;
                return_money <= 0;

            PAYMENT_VALIDATION:
                item_price <= 5'b0; // Placeholder for actual item prices
                dispense_item_id <= item_selected;
                error <= 0;
                return_money <= 0;

            DISPENSING_ITEM:
                item_price <= 5'b0; // Placeholder for actual item prices
                dispense_item_id <= item_selected;
                error <= 0;
                return_money <= 0;

            RETURN_CHANGE:
                change_amount <= 5'b0; // Placeholder for actual change calculation
                error <= 0;
                return_money <= 0;

            RETURN_MONEY:
                error <= 0;
                return_money <= 1;
                item_price <= 5'b0; // Placeholder for actual item prices
                dispense_item_id <= 0;
                change_amount <= 5'b0; // Placeholder for actual change calculation
                dispense_item <= 0;
                item_price <= 0;
                change_amount <= 0;
                dispense_item_id <= 0;
                error <= 0;
                return_money <= 0;
        endcase
    end

endmodule
