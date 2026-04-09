Module
// Implements a finite state machine that handles item selection,
// coin insertion, dispensing, change return, cancellation, and error handling.
// The machine supports valid coin values of 1, 2, 5, and 10 units.
// Only items with IDs 3'b001, 3'b010, 3'b011, and 3'b100 are valid.
// Prices are assigned as follows:
//   3'b001  -> Price = 5
//   3'b010  -> Price = 7
//   3'b011  -> Price = 9
//   3'b100  -> Price = 11
//
// The FSM states are:
//   IDLE             : Waiting for a transaction to start.
//   ITEM_SELECTION   : Waiting for a valid item selection.
//   PAYMENT_VALIDATION : Accumulating coins until price is met.
//   DISPENSING_ITEM  : Dispensing the item (one-cycle pulse).
//   RETURN_CHANGE    : Returning change (one-cycle pulse).
//   RETURN_MONEY     : Returning all inserted coins (one-cycle pulse) upon error/cancellation.
//
// Error conditions trigger an error pulse and transition to RETURN_MONEY.
//------------------------------------------------------------

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
  // State Declaration
  //-------------------------------------------------------------------------
  typedef enum logic [2:0] {
    IDLE             = 3'd0,
    ITEM_SELECTION   = 3'd1,
    PAYMENT_VALIDATION = 3'd2,
    DISPENSING_ITEM  = 3'd3,
    RETURN_CHANGE    = 3'd4,
    RETURN_MONEY     = 3'd5
  } state_t;

  state_t current_state, next_state;

  //-------------------------------------------------------------------------
  // Internal Registers and Wires
  //-------------------------------------------------------------------------
  // Accumulated coins (5-bit wide to cover prices and change)
  logic [4:0] coins_accumulated;
  // Registered item price and item ID (set during ITEM_SELECTION)
  logic [4:0] item_price_reg;
  logic [2:0] dispense_item_id_reg;
  // Registered change amount (calculated in DISPENSING_ITEM)
  logic [4:0] change_amount_reg;

  // One-cycle pulse registers for error and return_money signals
  logic error_reg, return_money_reg;

  // Registers to detect rising edges for toggle signals
  logic item_button_reg, cancel_reg;

  // Next state register values for sequential registers
  logic [4:0] coins_accumulated_next;
  logic [4:0] item_price_reg_next;
  logic [2:0] dispense_item_id_reg_next;
  logic [4:0] change_amount_reg_next;

  // Flag to indicate an error condition (set high for one cycle)
  logic error_detected;

  //-------------------------------------------------------------------------
  // Function: valid_coin
  // Returns true if coin_input is one of the valid coin values: 1, 2, 5, or 10.
  //-------------------------------------------------------------------------
  function automatic logic valid_coin (input logic [3:0] coin);
    if ((coin == 4'd1) || (coin == 4'd2) ||
        (coin == 4'd5) || (coin == 4'd10))
      valid_coin = 1;
    else
      valid_coin = 0;
  endfunction

  //-------------------------------------------------------------------------
  // Combinational Logic: Next State and Register Updates
  //-------------------------------------------------------------------------
  always_comb begin
    // Default assignments: retain current values unless changed
    next_state               = current_state;
    error_detected           = 1'b0;
    coins_accumulated_next   = coins_accumulated;
    item_price_reg_next      = item_price_reg;
    dispense_item_id_reg_next= dispense_item_id_reg;
    change_amount_reg_next   = change_amount_reg;

    case (current_state)
      //-------------------------------------------------------------------------
      // IDLE State
      //-------------------------------------------------------------------------
      IDLE: begin
        // If item_button rising edge, start a new transaction.
        if (item_button && !item_button_reg) begin
          next_state = ITEM_SELECTION;
        end
        // If coin inserted without item selection, trigger error.
        else if (coin_input != 4'd0) begin
          error_detected = 1;
          next_state     = RETURN_MONEY;
        end
      end

      //-------------------------------------------------------------------------
      // ITEM_SELECTION State
      //-------------------------------------------------------------------------
      ITEM_SELECTION: begin
        // Check for valid item selection.
        if ((item_selected == 3'b001) || (item_selected == 3'b010) ||
            (item_selected == 3'b011) || (item_selected == 3'b100)) begin
          // Set price and item ID based on selection.
          case (item_selected)
            3'b001: item_price_reg_next = 5'd5;
            3'b010: item_price_reg_next = 5'd7;
            3'b011: item_price_reg_next = 5'd9;
            3'b100: item_price_reg_next = 5'd11;
            default: item_price_reg_next = 5'd0;
          endcase
          dispense_item_id_reg_next = item_selected;
          coins_accumulated_next    = 5'd0;  // Reset coin accumulator.
          next_state                = PAYMENT_VALIDATION;
        end
        // Cancellation during item selection triggers error.
        else if (cancel && !cancel_reg) begin
          error_detected = 1;
          next_state     = RETURN_MONEY;
        end
        // Coin insertion in ITEM_SELECTION is invalid.
        else if (coin_input != 4'd0) begin
          error_detected = 1;
          next_state     = RETURN_MONEY;
        end
      end

      //-------------------------------------------------------------------------
      // PAYMENT_VALIDATION State
      //-------------------------------------------------------------------------
      PAYMENT_VALIDATION: begin
        // If a coin is inserted, validate and accumulate.
        if (coin_input != 4'd0) begin
          if (valid_coin(coin_input))
            coins_accumulated_next = coins_accumulated + coin_input;
          else begin
            error_detected = 1;
            next_state     = RETURN_MONEY;
          end
        end
        // If accumulated coins meet/exceed the item price, proceed to dispensing.
        if (coins_accumulated >= item_price_reg)
          next_state = DISPENSING_ITEM;
        // Cancellation during payment triggers error.
        else if (cancel && !cancel_reg) begin
          error_detected = 1;
          next_state     = RETURN_MONEY;
        end
      end

      //-------------------------------------------------------------------------
      // DISPENSING_ITEM State
      //-------------------------------------------------------------------------
      DISPENSING_ITEM: begin
        // Dispense the item for one cycle.
        if (coins_accumulated > item_price_reg) begin
          change_amount_reg_next = coins_accumulated - item_price_reg;
          next_state             = RETURN_CHANGE;
        end
        else if (coins_accumulated == item_price_reg) begin
          next_state = IDLE;
        end
        // Otherwise, remain in DISPENSING_ITEM (should not occur).
        else
          next_state = DISPENSING_ITEM;
      end

      //-------------------------------------------------------------------------
      // RETURN_CHANGE State
      //-------------------------------------------------------------------------
      RETURN_CHANGE: begin
        // Stay in RETURN_CHANGE for one cycle.
        next_state = IDLE;
      end

      //-------------------------------------------------------------------------
      // RETURN_MONEY State
      //-------------------------------------------------------------------------
      RETURN_MONEY: begin
        // Stay in RETURN_MONEY for one cycle.
        next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase
  end

  //-------------------------------------------------------------------------
  // Sequential Logic: State and Register Updates
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      current_state       <= IDLE;
      coins_accumulated   <= 5'd0;
      item_price_reg      <= 5'd0;
      dispense_item_id_reg<= 3'd0;
      change_amount_reg   <= 5'd0;
      error_reg           <= 1'b0;
      return_money_reg    <= 1'b0;
      item_button_reg     <= 1'b0;
      cancel_reg          <= 1'b0;
    end
    else begin
      // Detect rising edges for toggle signals.
      item_button_reg <= item_button;
      cancel_reg      <= cancel;
      
      // Update state and internal registers.
      current_state       <= next_state;
      coins_accumulated   <= coins_accumulated_next;
      item_price_reg      <= item_price_reg_next;
      dispense_item_id_reg<= dispense_item_id_reg_next;
      change_amount_reg   <= change_amount_reg_next;
      // Error pulse: active for one cycle.
      error_reg           <= error_detected;
      // Return money pulse: active in RETURN_MONEY state.
      return_money_reg    <= (current_state == RETURN_MONEY);
    end
  end

  //-------------------------------------------------------------------------
  // Output Assignments
  //-------------------------------------------------------------------------
  // In ITEM_SELECTION and PAYMENT_VALIDATION, display the selected item's price and ID.
  assign item_price       = ((current_state == ITEM_SELECTION) || 
                             (current_state == PAYMENT_VALIDATION)) ? item_price_reg : 5'd0;
  assign dispense_item_id = ((current_state == ITEM_SELECTION) || 
                             (current_state == PAYMENT_VALIDATION)) ? dispense_item_id_reg : 3'd0;
                             
  // In RETURN_CHANGE state, output the calculated change amount.
  assign change_amount    = (current_state == RETURN_CHANGE) ? change_amount_reg : 5'd0;
                             
  // Error and return_money outputs are driven by one-cycle pulse registers.
  assign error            = error_reg;
  assign return_money     = return_money_reg;
                             
  // One-cycle pulse for dispensing the item.
  assign dispense_item    = (current_state == DISPENSING_ITEM);
                             
  // One-cycle pulse for returning change.
  assign return_change    = (current_state == RETURN_CHANGE);

endmodule