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
    output reg return_money,
    output reg [4:0] return_money_value,
    output reg [4:0] item_selected_display,
    output reg dispense_item_output
);

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        dispense_item <= 1'b0;
        return_change <= 1'b0;
        item_price <= 0;
        change_amount <= 0;
        dispense_item_id <= 3'd0;
        error <= 1'b0;
        return_money <= 1'b0;
        return_money_value <= 5'b0;
        item_selected_display <= 0;
        dispense_item_output <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                if (item_button) begin
                    state <= ITEM_SELECTION;
                    dispense_item <= 1'b0;
                    item_price <= 0;
                end
            end
            ITEM_SELECTION: begin
                if (item_selected == 3'b001 || item_selected == 3'b010 || item_selected == 3'b011) begin
                    state <= PAYMENT_VALIDATION;
                    item_price <= item_price[item_selected];
                end else begin
                    state <= RETURN_MONEY;
                end
            end
            PAYMENT_VALIDATION: begin
                if (coin_input != 1'b0 && (coin_input != 1'b2 || coin_input != 1'b5 || coin_input != 1'b10)) begin
                    state <= ERROR;
                    error <= 1'b1;
                    return_money <= 1'b1;
                    return_money_value <= 5'b0;
                    dispense_item_output <= 1'b0;
                    item_price <= 0;
                end
                else if (coin_input >= 1'b1 && coin_input <= 1'b3) begin
                    coins_accumulated += coin_input;
                end
                if (coins_accumulated >= item_price) begin
                    state <= DISPENSING_ITEM;
                end
            end
            DISPENSING_ITEM: begin
                dispense_item_output <= 1'b1;
                dispense_item_id <= item_id;
                state <= IDLE;
            end
            RETURN_MONEY: begin
                state <= RETURN_CHANGE;
                return_change <= 1'b1;
            end
            RETURN_CHANGE: begin
                if (change_amount > 0) begin
                    return_change <= 1'b1;
                end
                if (coins_accumulated < item_price) begin
                    state <= ERROR;
                    error <= 1'b1;
                    return_money <= 1'b1;
                    return_money_value <= 5'b0;
                    dispense_item_output <= 1'b0;
                    item_price <= 0;
                end
                else if (coins_accumulated == item_price) begin
                    state <= IDLE;
                end
            end
            default: state <= IDLE;
        endcase
    end
end;

endmodule
