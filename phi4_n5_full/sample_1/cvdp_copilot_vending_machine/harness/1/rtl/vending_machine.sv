module vending_machine (
    input  logic         clk,
    input  logic         rst,
    input  logic         item_button,
    input  logic [2:0]   item_selected,
    input  logic [3:0]   coin_input,
    input  logic         cancel,
    output logic         dispense_item,
    output logic         return_change,
    output logic [4:0]   item_price,
    output logic [4:0]   change_amount,
    output logic [2:0]   dispense_item_id,
    output logic         error,
    output logic         return_money
);

  // Define FSM states
  typedef enum logic [2:0] {
    IDLE              = 3'd0,
    ITEM_SELECTION    = 3'd1,
    PAYMENT_VALIDATION= 3'd2,
    DISPENSING_ITEM   = 3'd3,
    RETURN_CHANGE     = 3'd4,
    RETURN_MONEY      = 3'd5
  } state_t;

  state_t state, next_state;

  // Registers for coin accumulation and selected item info
  logic [5:0] coins_accumulated;  // 6-bit accumulator to allow for excess coins
  logic [4:0] current_item_price;
  logic [2:0] current_item_id;

  // Registers for edge detection of toggle signals
  logic item_button_prev;
  logic cancel_prev;

  // Combinational block: Next state logic and output assignments
  always_comb begin
    // Default assignments
    next_state         = state;
    dispense_item      = 1'b0;
    return_change      = 1'b0;
    error              = 1'b0;
    return_money       = 1'b0;
    item_price         = 5'd0;
    change_amount      = 5'd0;
    dispense_item_id   = 3'd0;

    case (state)
      IDLE: begin
        // If coins are inserted without item_button press, trigger error.
        if (coin_input != 4'd0) begin
          next_state = RETURN_MONEY;
        end
        // Detect rising edge of item_button to start transaction.
        else if (item_button && !item_button_prev) begin
          next_state = ITEM_SELECTION;
        end
      end

      ITEM_SELECTION: begin
        // Cancel transaction: rising edge of cancel triggers error.
        if (cancel && !cancel_prev) begin
          next_state = RETURN_MONEY;
        end
        // Valid item selection: only 001, 010, 011, and 100 are accepted.
        else if ((item_selected == 3'b001) ||
                 (item_selected == 3'b010) ||
                 (item_selected == 3'b011) ||
                 (item_selected == 3'b100)) begin
          // Map item selection to item price and ID.
          case (item_selected)
            3'b001: current_item_price = 5'd5;
            3'b010: current_item_price = 5'd7;
            3'b011: current_item_price = 5'd10;
            3'b100: current_item_price = 5'd15;
            default: current_item_price = 5'd0;
          endcase
          current_item_id = item_selected;
          next_state = PAYMENT_VALIDATION;
        end
        // Invalid item selection triggers error.
        else begin
          next_state = RETURN_MONEY;
        end
      end

      PAYMENT_VALIDATION: begin
        // Cancel transaction during payment.
        if (cancel && !cancel_prev) begin
          next_state = RETURN_MONEY;
        end
        else begin
          // Only accept coin values of 1, 2, 5, or 10.
          if (((coin_input == 4'd1) || (coin_input == 4'd2) ||
               (coin_input == 4'd5) || (coin_input == 4'd10))) begin
            // Check if accumulated coins meet/exceed the item price.
            if ((coins_accumulated + coin_input) >= current_item_price) begin
              next_state = DISPENSING_ITEM;
            end
            else begin
              next_state = PAYMENT_VALIDATION;
            end
          end
          // Invalid coin input triggers error.
          else begin
            next_state = RETURN_MONEY;
          end
        end
      end

      DISPENSING_ITEM: begin
        // Assert dispense_item pulse for one cycle.
        dispense_item = 1'b1;
        // If excess coins were inserted, calculate change and move to RETURN_CHANGE.
        if (coins_accumulated > current_item_price) begin
          next_state = RETURN_CHANGE;
        end
        else begin
          next_state = IDLE;
        end
      end

      RETURN_CHANGE: begin
        // Assert return_change pulse for one cycle.
        return_change = 1'b1;
        change_amount = coins_accumulated - current_item_price;
        next_state = IDLE;
      end

      RETURN_MONEY: begin
        // Assert return_money pulse for one cycle.
        return_money = 1'b1;
        next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase

    // Generate error pulse when transitioning to RETURN_MONEY from a non-RETURN_MONEY state.
    if ((next_state == RETURN_MONEY) && (state != RETURN_MONEY)) begin
      error = 1'b1;
    end
  end

  // Sequential block: Update state and registers on clock edge.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state             <= IDLE;
      coins_accumulated <= 6'd0;
      current_item_price<= 5'd0;
      current_item_id   <= 3'd0;
      item_button_prev  <= 1'b0;
      cancel_prev       <= 1'b0;
    end
    else begin
      state <= next_state;
      // Update edge detection registers.
      item_button_prev <= item_button;
      cancel_prev      <= cancel;
      // In PAYMENT_VALIDATION state, accumulate valid coin input.
      if (state == PAYMENT_VALIDATION) begin
        if (((coin_input == 4'd1) || (coin_input == 4'd2) ||
             (coin_input == 4'd5) || (coin_input == 4'd10))) begin
          coins_accumulated <= coins_accumulated + coin_input;
        end
      end
      // No coin accumulation in other states.
    end
  end

  // Output block: Drive item_price and dispense_item_id only during ITEM_SELECTION.
  always_comb begin
    if (state == ITEM_SELECTION) begin
      item_price      = current_item_price;
      dispense_item_id= current_item_id;
    end
    else begin
      item_price      = 5'd0;
      dispense_item_id= 3'd0;
    end
  end

endmodule