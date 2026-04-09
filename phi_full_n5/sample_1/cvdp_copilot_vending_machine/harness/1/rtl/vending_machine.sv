module vending_machine (
    input clk,
    input rst,
    input item_button,
    input [2:0] item_selected,
    input [3:0] coin_input,
    input cancel,
    output reg dispense_item,
    output reg return_change,
    output [4:0] item_price,
    output [4:0] change_amount,
    output [2:0] dispense_item_id,
    output error,
    output return_money
);

    // State declarations
    localparam IDLE = 2'b00,
              ITEM_SELECTION = 2'b01,
              PAYMENT_VALIDATION = 2'b10,
              DISPENSING_ITEM = 2'b11;

    // Internal state register
    reg [2:0] current_state, next_state;
    reg [4:0] coins_accumulated = 0;
    reg [4:0] item_price_display = 0;
    reg [4:0] change_to_return = 0;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            coins_accumulated <= 0;
            item_price_display <= 0;
            change_to_return <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    // State transition conditions
    always @(current_state or item_selected or coin_input or cancel) begin
        case (current_state)
            IDLE: begin
                if (item_button) begin
                    next_state <= ITEM_SELECTION;
                end else begin
                    next_state <= IDLE;
                end
            end
            ITEM_SELECTION: begin
                if (item_selected >= 3'b001 && item_selected <= 3'b100) begin
                    next_state <= PAYMENT_VALIDATION;
                    item_price_display <= {item_selected[2:0], 4'b0000}; // Example prices, replace with actual prices
                end else begin
                    next_state <= RETURN_MONEY;
                end
            end
            PAYMENT_VALIDATION: begin
                if (coin_input == 4'b0000 || coin_input == 4'b0001 || coin_input == 4'b0100 || coin_input == 4'b1000) begin
                    coins_accumulated <= coins_accumulated + coin_input;
                    if (coins_accumulated >= item_price_display) begin
                        next_state <= DISPENSING_ITEM;
                    end else begin
                        next_state <= PAYMENT_VALIDATION;
                    end
                end else begin
                    error <= 1'b1;
                    next_state <= RETURN_MONEY;
                end
            end
            DISPENSING_ITEM: begin
                dispense_item <= 1'b1;
                if (coins_accumulated > item_price_display) begin
                    change_to_return <= coins_accumulated - item_price_display;
                    next_state <= RETURN_CHANGE;
                end else begin
                    next_state <= IDLE;
                end
            end
            RETURN_CHANGE: begin
                return_change <= 1'b1;
                next_state <= IDLE;
            end
            RETURN_MONEY: begin
                return_money <= 1'b1;
                next_state <= IDLE;
            end
            default: begin
                next_state <= IDLE;
            end
        end
    end

    // Output logic
    always @(current_state or dispense_item or return_change or item_price_display or change_to_return or return_money or error) begin
        case (current_state)
            IDLE: begin
                dispense_item <= 0;
                return_change <= 0;
                item_price_display <= 0;
                change_to_return <= 0;
                dispense_item_id <= 0;
                error <= 0;
                return_money <= 0;
            end
            ITEM_SELECTION: begin
                dispense_item <= 0;
                return_change <= 0;
                item_price_display <= item_price_display;
                change_to_return <= 0;
                dispense_item_id <= item_selected;
                error <= 0;
                return_money <= 0;
            end
            PAYMENT_VALIDATION: begin
                dispense_item <= 0;
                return_change <= 0;
                item_price_display <= item_price_display;
                change_to_return <= 0;
                dispense_item_id <= 0;
                error <= 0;
                return_money <= 0;
            end
            DISPENSING_ITEM: begin
                dispense_item <= 1;
                return_change <= 0;
                item_price_display <= item_price_display;
                change_to_return <= 0;
                dispense_item_id <= dispense_item_id;
                error <= 0;
                return_money <= 0;
            end
            RETURN_CHANGE: begin
                dispense_item <= 0;
                return_change <= 1;
                item_price_display <= 0;
                change_to_return <= change_to_return;
                dispense_item_id <= 0;
                error <= 0;
                return_money <= 0;
            end
            RETURN_MONEY: begin
                dispense_item <= 0;
                return_change <= 0;
                item_price_display <= 0;
                change_to_return <= 0;
                dispense_item_id <= 0;
                error <= 0;
                return_money <= 1;
            end
            default: begin
                dispense_item <= 0;
                return_change <= 0;
                item_price_display <= 0;
                change_to_return <= 0;
                dispense_item_id <= 0;
                error <= 1;
                return_money <= 0;
            end
        end
    end
endmodule
