module vending_machine(
    input clk,
    input rst,
    input item_button,
    input [2:0] item_selected,
    input [3:0] coin_input,
    output reg dispense_item,
    output reg return_change,
    output [4:0] item_price,
    output [4:0] change_amount,
    output [2:0] dispense_item_id,
    output error,
    output return_money
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

    reg [1:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // State transition logic
    always @(current_state or item_button or coin_input or item_selected or cancel) begin
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
                    item_price <= 5'b0000_0000; // Placeholder, actual price logic needed
                end else begin
                    error <= 1'b1;
                    next_state <= RETURN_MONEY;
                end
            end
            PAYMENT_VALIDATION: begin
                // Accumulate coin input
                if (coin_input == 4'b0000 || coin_input == 4'b0001 || coin_input == 4'b0010 || coin_input == 4'b0100) begin
                    if (coin_input <= 5'b10000 - item_price[4:0]) begin
                        next_state <= DISPENSING_ITEM;
                    end else begin
                        error <= 1'b1;
                        next_state <= RETURN_MONEY;
                    end
                end else begin
                    error <= 1'b1;
                    next_state <= RETURN_MONEY;
                end
            end
            DISPENSING_ITEM: begin
                dispense_item <= 1'b1;
                if (coin_input > item_price[4:0]) begin
                    change_amount <= coin_input - item_price[4:0];
                    return_change <= 1'b1;
                    next_state <= RETURN_CHANGE;
                end else {
                    next_state <= IDLE;
                }
            end
            RETURN_CHANGE: begin
                return_change <= 1'b1;
                next_state <= IDLE;
            end
            RETURN_MONEY: begin
                return_money <= 1'b1;
                next_state <= IDLE;
            end
        end
    end

    // Output logic
    always @(posedge clk) begin
        if (rst) begin
            dispense_item <= 1'b0;
            return_change <= 1'b0;
            dispense_item_id <= 3'b000;
            error <= 1'b0;
            return_money <= 1'b0;
        end else begin
            dispense_item <= next_state == DISPENSING_ITEM ? 1'b1 : 1'b0;
            return_change <= next_state == RETURN_CHANGE ? 1'b1 : 1'b0;
            dispense_item_id <= next_state == DISPENSING_ITEM ? item_selected : 3'b000;
            error <= next_state == ITEM_SELECTION || next_state == PAYMENT_VALIDATION || next_state == RETURN_CHANGE || next_state == RETURN_MONEY ? 1'b1 : 1'b0;
            return_money <= next_state == RETURN_MONEY ? 1'b1 : 1'b0;
        end
    end
endmodule
