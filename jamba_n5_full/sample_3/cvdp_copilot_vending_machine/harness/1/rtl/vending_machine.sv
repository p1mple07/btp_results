`timescale 1ns / 1ps

interface vending_machine_if;
    input clk;
    input rst;
    input item_button;
    input [2:0] item_selected;
    input [3:0] coin_input;
    input cancel;

    output reg dispense_item;
    output reg return_change;
    output reg [4:0] item_price;
    output reg [4:0] change_amount;
    output reg [2:0] dispense_item_id;
    output reg error;
    output reg return_money;
endinterface

module vending_machine (input clk, input rst, input item_button, input [2:0] item_selected, input [3:0] coin_input, input cancel);
    localparam itidle = 1'b0;
    localparam ititem_select = 1'b1;
    localparam itpayment = 1'b2;
    localparam itdispense = 1'b3;
    localparam itreturn_change = 1'b4;
    localparam itreturntm = 1'b5;
    localparam itidle_after_canc = 1'b6;

    reg [4:0] item_price_reg;
    reg change_amount_reg;
    reg dispense_item_id_reg;
    reg error_flag;
    reg return_money_flag;
    reg dispense_item_done;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            item_price_reg <= 5'd0;
            change_amount_reg <= 5'd0;
            dispense_item_id_reg <= 3'b000;
            error_flag <= 0;
            return_money_flag <= 0;
            dispense_item_done <= 0;
        end else begin
            case (item_select)
                itidle: begin
                    if (item_button) begin
                        item_select <= ititem_select;
                    end
                end
                ititem_select: begin
                    if (item_selected[0] == 1'b0) begin
                        item_select <= itidle;
                    end
                end
                itpayment: begin
                    if (coin_input[0] != 1'b0 && coin_input[0] != 1'b1 && coin_input[0] != 1'b2 && coin_input[0] != 1'b5 && coin_input[0] != 1'b10) begin
                        error_flag <= 1;
                        return_money_flag <= 1;
                        item_price_reg <= 5'd0;
                        change_amount_reg <= 5'd0;
                        dispense_item_id_reg <= 3'b000;
                        dispense_item_done <= 0;
                    end else begin
                        coin_accumulated <= coin_accumulated + coin_input[0];
                    end
                end
                itdispense: begin
                    if (coin_accumulated >= item_price_reg) begin
                        dispense_item_done <= 1;
                        dispense_item_id_reg <= 3'b001;
                        item_price_reg <= 5'd0;
                        change_amount_reg <= 5'd0;
                        return_money_flag <= 0;
                    end else begin
                        error_flag <= 1;
                        return_money_flag <= 1;
                        dispense_item_done <= 0;
                    end
                end
                itreturn_change: begin
                    if (coin_accumulated > item_price_reg) begin
                        change_amount_reg <= coin_accumulated - item_price_reg;
                        dispense_item_done <= 1;
                        item_price_reg <= 5'd0;
                    end else begin
                        return_money_flag <= 0;
                    end
                end
                itreturntm: begin
                    if (return_money_flag) begin
                        return_money_flag <= 0;
                        dispense_item_done <= 1;
                        item_price_reg <= 5'd0;
                    end
                end
                itidle_after_canc: begin
                    error_flag <= 1;
                    return_money_flag <= 1;
                    dispense_item_done <= 0;
                end
            endcase
        end
    end
endmodule
