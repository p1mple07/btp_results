module vending_machine (
    input  clk,
    input  rst,
    input  item_button,
    input  [2:0] item_selected,
    input  [3:0] coin_input,
    input  cancel,
    output reg dispense_item,
    output reg return_change,
    output reg [4:0] item_price,
    output reg [4:0] change_amount,
    output reg [2:0] dispense_item_id,
    output reg error,
    output reg return_money
);

    // State definitions
    localparam ITERATION_IDLE = 0;
    localparam ITERATION_ITEM_SELECTION = 1;
    localparam ITERATION_PAYMENT_VALIDATION = 2;
    localparam ITERATION_DISPENSING_ITEM = 3;
    localparam ITERATION_RETURN_CHANGE = 4;
    localparam ITERATION_RETURN_MONEY = 5;

    reg [2:0] state;
    reg [2:0] next_state;
    reg item_pressed;
    reg item_displayed;
    reg coins_accumulated;
    reg change_required;
    reg dispense_triggered;
    reg error_flag;

    initial begin
        state = ITERATION_IDLE;
        next_state = ITERATION_IDLE;
        item_pressed = 0;
        item_displayed = 0;
        coins_accumulated = 0;
        change_required = 0;
        dispense_triggered = 0;
        error_flag = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= ITERATION_IDLE;
            next_state <= ITERATION_IDLE;
            item_pressed <= 0;
            item_displayed <= 0;
            coins_accumulated <= 0;
            change_required <= 0;
            dispense_triggered <= 0;
            error_flag <= 0;
        } else begin
            item_pressed <= item_button;
        end
    end

    always @(item_pressed or coin_input) begin
        case (state)
            ITERATION_IDLE: begin
                if (item_pressed) begin
                    state <= ITERATION_ITEM_SELECTION;
                    next_state <= ITERATION_ITEM_SELECTION;
                end
                item_pressed <= 0;
            end
            ITERATION_ITEM_SELECTION: begin
                if (item_selected == 3'b001) begin
                    state <= ITERATION_PAYMENT_VALIDATION;
                    next_state <= ITERATION_PAYMENT_VALIDATION;
                end else if (item_selected == 3'b010) begin
                    state <= ITERATION_PAYMENT_VALIDATION;
                    next_state <= ITERATION_PAYMENT_VALIDATION;
                end else if (item_selected == 3'b011) begin
                    state <= ITERATION_PAYMENT_VALIDATION;
                    next_state <= ITERATION_PAYMENT_VALIDATION;
                end else if (item_selected == 3'b100) begin
                    state <= ITERATION_PAYMENT_VALIDATION;
                    next_state <= ITERATION_PAYMENT_VALIDATION;
                end else if (item_selected < 3'b001 or item_selected > 3'b100) begin
                    state <= ITERATION_ERROR;
                    next_state <= ITERATION_ERROR;
                end else if (coin_input != 4'b0000 && coin_input != 4'b0001 && coin_input != 4'b0010 && coin_input != 4'b0100) begin
                    state <= ITERATION_ERROR;
                    next_state <= ITERATION_ERROR;
                end
            end
            ITERATION_PAYMENT_VALIDATION: begin
                if (item_displayed) begin
                    item_price = item_selected[3];
                    dispense_item_id = 3'b000;
                    next_state <= ITERATION_DISPENSING_ITEM;
                end else if (coin_input == 4'b0000) begin
                    state <= ITERATION_DISPENSING_ITEM;
                    next_state <= ITERATION_DISPENSING_ITEM;
                end else if (coin_input == 4'b0001) begin
                    state <= ITERATION_PAYMENT_VALIDATION;
                    next_state <= ITERATION_PAYMENT_VALIDATION;
                end else begin
                    state <= ITERATION_ERROR;
                    next_state <= ITERATION_ERROR;
                end
            end
            ITERATION_DISPENSING_ITEM: begin
                dispense_triggered = 1;
                if (coin_input == 4'b0000) begin
                    coins_accumulated += 1;
                    if (coins_accumulated >= item_price) begin
                        state <= ITERATION_RETURN_CHANGE;
                        next_state <= ITERATION_RETURN_CHANGE;
                    end
                end else begin
                    state <= ITERATION_RETURN_CHANGE;
                    next_state <= ITERATION_RETURN_CHANGE;
                end
            end
            ITERATION_RETURN_CHANGE: begin
                if (coin_input == 4'b0010) begin
                    change_required = coin_input;
                    coins_accumulated = 0;
                    dispense_item_id = 3'b001;
                    next_state <= ITERATION_RETURN_MONEY;
                end else begin
                    state <= ITERATION_RETURN_MONEY;
                    next_state <= ITERATION_RETURN_MONEY;
                end
            end
            ITERATION_RETURN_MONEY: begin
                if (coin_input == 4'b0000) begin
                    state <= ITERATION_IDLE;
                    next_state <= ITERATION_IDLE;
                end else if (coin_input == 4'b0001) begin
                    state <= ITERATION_IDLE;
                    next_state <= ITERATION_IDLE;
                end else if (coin_input == 4'b0010) begin
                    state <= ITERATION_IDLE;
                    next_state <= ITERATION_IDLE;
                end else begin
                    state <= ITERATION_IDLE;
                    next_state <= ITERATION_IDLE;
                end
            end
        end
    end

endmodule
