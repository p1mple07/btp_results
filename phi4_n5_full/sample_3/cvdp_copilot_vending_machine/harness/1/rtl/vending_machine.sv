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

  //-------------------------------------------------------------------------
  // Local Parameters for FSM States
  //-------------------------------------------------------------------------
  typedef enum logic [2:0] {
    IDLE                = 3'd0,
    ITEM_SELECTION      = 3'd1,
    PAYMENT_VALIDATION  = 3'd2,
    DISPENSING_ITEM     = 3'd3,
    RETURN_CHANGE       = 3'd4,
    RETURN_MONEY        = 3'd5
  } state_t;

  //-------------------------------------------------------------------------
  // Internal Registers and Wires
  //-------------------------------------------------------------------------
  state_t state, next_state;
  logic [7:0] coins_accum;  // 8-bit accumulator for coin values
  logic [4:0] price_reg;    // Registered item price

  // Registers for one-cycle pulse outputs
  logic dispense_item_reg;
  logic return_change_reg;
  logic return_money_reg;
  logic error_reg;
  logic error_flag;  // Flag to indicate an error condition

  // Registers for detecting rising edges of toggle signals
  logic item_button_reg;
  logic cancel_reg;
  logic item_button_rising;
  logic cancel_rising;

  //-------------------------------------------------------------------------
  // Rising Edge Detection for Toggle Signals
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      item_button_reg <= 1'b0;
      cancel_reg      <= 1'b0;
    end else begin
      item_button_reg <= item_button;
      cancel_reg      <= cancel;
    end
  end

  assign item_button_rising = item_button && !item_button_reg;
  assign cancel_rising      = cancel      && !cancel_reg;

  //-------------------------------------------------------------------------
  // FSM: Sequential Logic
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state             <= IDLE;
      coins_accum       <= 8'd0;
      price_reg         <= 5'd0;
      dispense_item_reg <= 1'b0;
      return_change_reg <= 1'b0;
      return_money_reg  <= 1'b0;
      error_reg         <= 1'b0;
      error_flag        <= 1'b0;
    end else begin
      // Update rising edge registers (already done above)

      // Determine Next State based on current state and inputs
      case (state)
        IDLE: begin
          // In IDLE, if any coin is inserted without item_button, trigger error.
          if (coin_input != 4'd0) begin
            next_state = RETURN_MONEY;
          end else if (item_button_rising) begin
            next_state = ITEM_SELECTION;
          end else begin
            next_state = IDLE;
          end
        end

        ITEM_SELECTION: begin
          // If cancel is pressed, trigger error.
          if (cancel_rising) begin
            next_state = RETURN_MONEY;
          end else if (
            (item_selected == 3'b001) ||
            (item_selected == 3'b010) ||
            (item_selected == 3'b011) ||
            (item_selected == 3'b100)
          ) begin
            // Set price based on the selected item.
            case (item_selected)
              3'b001: price_reg = 5;    // Price: 5 units
              3'b010: price_reg = 10;   // Price: 10 units
              3'b011: price_reg = 15;   // Price: 15 units
              3'b100: price_reg = 20;   // Price: 20 units
              default: price_reg = 5'd0;
            endcase
            next_state = PAYMENT_VALIDATION;
          end else begin
            // Invalid item selection triggers error.
            next_state = RETURN_MONEY;
          end
        end

        PAYMENT_VALIDATION: begin
          // If cancel is pressed, trigger error.
          if (cancel_rising) begin
            next_state = RETURN_MONEY;
          end else if (
            (coin_input == 4'd1) ||
            (coin_input == 4'd2) ||
            (coin_input == 4'd5) ||
            (coin_input == 4'd10)
          ) begin
            // Accumulate valid coin input.
            coins_accum <= coins_accum + coin_input;
            if (coins_accum >= price_reg) begin
              next_state = DISPENSING_ITEM;
            end else begin
              next_state = PAYMENT_VALIDATION;
            end
          end else begin
            // Invalid coin value triggers error.
            next_state = RETURN_MONEY;
          end
        end

        DISPENSING_ITEM: begin
          // Dispense item for one clock cycle.
          if (cancel_rising) begin
            next_state = RETURN_MONEY;
          end else begin
            if (coins_accum > price_reg) begin
              next_state = RETURN_CHANGE;
            end else begin
              next_state = IDLE;
            end
          end
        end

        RETURN_CHANGE: begin
          // After dispensing, return change if any.
          next_state = IDLE;
        end

        RETURN_MONEY: begin
          // Refund all inserted coins due to cancellation or error.
          next_state = IDLE;
        end

        default: next_state = IDLE;
      endcase

      // Set error flag if transitioning to RETURN_MONEY due to an error.
      if (next_state == RETURN_MONEY) begin
        if (
          (state == ITEM_SELECTION && !(
            (item_selected == 3'b001) ||
            (item_selected == 3'b010) ||
            (item_selected == 3'b011) ||
            (item_selected == 3'b100)
          )) ||
          (state == PAYMENT_VALIDATION && !(
            (coin_input == 4'd1) ||
            (coin_input == 4'd2) ||
            (coin_input == 4'd5) ||
            (coin_input == 4'd10)
          )) ||
          (state == IDLE && coin_input != 4'd0)
        ) begin
          error_flag <= 1'b1;
        end else begin
          error_flag <= 1'b0;
        end
      end else begin
        error_flag <= 1'b0;
      end

      // Update coins_accum: if in PAYMENT_VALIDATION with valid coin, accumulate;
      // if an error occurs (transitioning to RETURN_MONEY), clear the accumulator.
      if (state == PAYMENT_VALIDATION && (
            (coin_input == 4'd1) ||
            (coin_input == 4'd2) ||
            (coin_input == 4'd5) ||
            (coin_input == 4'd10)
          )) begin
        coins_accum <= coins_accum + coin_input;
      end else if (next_state == RETURN_MONEY) begin
        coins_accum <= 8'd0;
      end

      // Generate one-cycle pulse outputs based on next state.
      dispense_item_reg   <= (next_state == DISPENSING_ITEM);
      return_change_reg   <= (next_state == RETURN_CHANGE);
      return_money_reg    <= (next_state == RETURN_MONEY);
      error_reg           <= (next_state == RETURN_MONEY && error_flag);

      // Update the state register.
      state <= next_state;
    end
  end

  //-------------------------------------------------------------------------
  // Output Assignments
  //-------------------------------------------------------------------------
  assign dispense_item   = dispense_item_reg;
  assign return_change   = return_change_reg;
  assign error           = error_reg;
  assign return_money    = return_money_reg;
  assign item_price      = price_reg;  // Displays the price once item is selected

  // change_amount is valid only in the RETURN_CHANGE state.
  assign change_amount   = (state == RETURN_CHANGE) ? (coins_accum - price_reg) : 5'd0;

  // dispense_item_id outputs the selected item ID only during dispensing.
  assign dispense_item_id = (state == DISPENSING_ITEM) ? item_selected : 3'd0;

endmodule