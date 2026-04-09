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
  // FSM States
  //-------------------------------------------------------------------------
  typedef enum logic [2:0] {
    IDLE              = 3'b000,
    ITEM_SELECTION    = 3'b001,
    PAYMENT_VALIDATION= 3'b010,
    DISPENSING_ITEM   = 3'b011,
    RETURN_CHANGE     = 3'b100,
    RETURN_MONEY      = 3'b101
  } state_t;

  //-------------------------------------------------------------------------
  // Internal Registers
  //-------------------------------------------------------------------------
  state_t state;
  // Accumulated coins (assumed 5-bit wide to cover typical transaction amounts)
  logic [4:0] coins_accumulated;
  // Registered selected item and its price
  logic [2:0] item_selected_reg;
  logic [4:0] item_price_reg;
  // Change amount to be returned
  logic [4:0] change_amount_reg;
  // One-cycle pulse registers for error, dispense, change, and money return
  logic error_reg;
  logic dispense_item_reg;
  logic return_change_reg;
  logic return_money_reg;
  // Registers to detect rising edges of item_button and cancel signals
  logic item_button_reg;
  logic cancel_reg;

  //-------------------------------------------------------------------------
  // Main FSM Process
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state                  <= IDLE;
      coins_accumulated      <= 5'd0;
      item_selected_reg      <= 3'd0;
      item_price_reg         <= 5'd0;
      change_amount_reg      <= 5'd0;
      error_reg              <= 1'b0;
      dispense_item_reg      <= 1'b0;
      return_change_reg      <= 1'b0;
      return_money_reg       <= 1'b0;
      item_button_reg        <= 1'b0;
      cancel_reg             <= 1'b0;
    end
    else begin
      // Update button registers to detect rising edges
      item_button_reg <= item_button;
      cancel_reg      <= cancel;

      // Default: clear one-cycle pulses
      error_reg       <= 1'b0;
      dispense_item_reg <= 1'b0;
      return_change_reg <= 1'b0;
      return_money_reg  <= 1'b0;

      case (state)
        //-------------------------------------------------------------------------
        // IDLE State
        //-------------------------------------------------------------------------
        IDLE: begin
          // If coins are inserted before item selection, trigger error.
          if (coin_input != 4'd0) begin
            error_reg <= 1;
            state     <= RETURN_MONEY;
          end
          // Transition to ITEM_SELECTION on rising edge of item_button.
          else if (item_button && !item_button_reg) begin
            state <= ITEM_SELECTION;
          end
          else begin
            state <= IDLE;
          end
        end

        //-------------------------------------------------------------------------
        // ITEM_SELECTION State
        //-------------------------------------------------------------------------
        ITEM_SELECTION: begin
          // If cancel is pressed, trigger error.
          if (cancel && !cancel_reg) begin
            error_reg <= 1;
            state     <= RETURN_MONEY;
          end
          // Also, if coins are inserted before confirming the item, trigger error.
          else if (coin_input != 4'd0) begin
            error_reg <= 1;
            state     <= RETURN_MONEY;
          end
          else begin
            // Validate item selection: only valid if 3'b001, 3'b010, 3'b011, or 3'b100.
            if ((item_selected == 3'b001) || (item_selected == 3'b010) ||
                (item_selected == 3'b011) || (item_selected == 3'b100)) begin
              item_selected_reg <= item_selected;
              // Map item_selected to a price.
              case (item_selected)
                3'b001: item_price_reg <= 5'd5;
                3'b010: item_price_reg <= 5'd10;
                3'b011: item_price_reg <= 5'd15;
                3'b100: item_price_reg <= 5'd20;
                default: item_price_reg <= 5'd0;
              endcase
              // Transition to PAYMENT_VALIDATION.
              state <= PAYMENT_VALIDATION;
            end
            else begin
              error_reg <= 1;
              state     <= RETURN_MONEY;
            end
          end
        end

        //-------------------------------------------------------------------------
        // PAYMENT_VALIDATION State
        //-------------------------------------------------------------------------
        PAYMENT_VALIDATION: begin
          // If cancel is pressed, trigger error.
          if (cancel && !cancel_reg) begin
            error_reg <= 1;
            state     <= RETURN_MONEY;
          end
          else begin
            // Validate coin_input: only accept coins of value 1, 2, 5, or 10.
            if ((coin_input == 4'd1) || (coin_input == 4'd2) ||
                (coin_input == 4'd5) || (coin_input == 4'd10)) begin
              coins_accumulated <= coins_accumulated + coin_input;
              // If accumulated coins meet/exceed the item price, move to DISPENSING_ITEM.
              if (coins_accumulated >= item_price_reg) begin
                state <= DISPENSING_ITEM;
              end
            end
            else begin
              error_reg <= 1;
              state     <= RETURN_MONEY;
            end
          end
        end

        //-------------------------------------------------------------------------
        // DISPENSING_ITEM State
        //-------------------------------------------------------------------------
        DISPENSING_ITEM: begin
          // Assert dispense_item pulse for one cycle.
          dispense_item_reg <= 1;
          // If cancel is pressed during dispensing, trigger error.
          if (cancel && !cancel_reg) begin
            error_reg <= 1;
            state     <= RETURN_MONEY;
          end
          else begin
            // If excess coins were inserted, calculate change.
            if (coins_accumulated > item_price_reg) begin
              change_amount_reg <= coins_accumulated - item_price_reg;
              state             <= RETURN_CHANGE;
            end
            else begin
              state <= IDLE;
            end
          end
        end

        //-------------------------------------------------------------------------
        // RETURN_CHANGE State
        //-------------------------------------------------------------------------
        RETURN_CHANGE: begin
          // Assert return_change pulse for one cycle.
          return_change_reg <= 1;
          state             <= IDLE;
        end

        //-------------------------------------------------------------------------
        // RETURN_MONEY State
        //-------------------------------------------------------------------------
        RETURN_MONEY: begin
          // Assert return_money pulse for one cycle.
          return_money_reg <= 1;
          state            <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Output Assignments
  //-------------------------------------------------------------------------
  // One-cycle pulse outputs.
  assign error         = error_reg;
  assign dispense_item = dispense_item_reg;
  assign return_change = return_change_reg;
  assign return_money  = return_money_reg;

  // Display the item price once selected.
  assign item_price = item_price_reg;

  // Output the change amount only during RETURN_CHANGE state.
  assign change_amount = (state == RETURN_CHANGE) ? change_amount_reg : 5'd0;

  // Output the dispensed item ID only during DISPENSING_ITEM state.
  assign dispense_item_id = (state == DISPENSING_ITEM) ? item_selected_reg : 3'd0;

endmodule