module digital_dice_roller (
    input  logic         clk,
    input  logic         reset_n,
    input  logic         button,
    output logic [2:0]   dice_value
);

  // Define FSM states
  typedef enum logic { IDLE, ROLLING } state_t;
  state_t state, next_state;

  // Internal 3-bit counter used during rolling
  logic [2:0] counter;

  // Next state combinational logic
  always_comb begin
    // Default: hold current state
    next_state = state;
    case (state)
      IDLE: begin
        // Transition to ROLLING if button is pressed
        if (button)
          next_state = ROLLING;
      end
      ROLLING: begin
        // Return to IDLE when button is released
        if (!button)
          next_state = IDLE;
      end
    endcase
  end

  // Sequential logic for state, counter, and output update
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      // Asynchronous reset: go to IDLE and initialize dice_value and counter to 1
      state      <= IDLE;
      counter    <= 3'd1;
      dice_value <= 3'd1;
    end
    else begin
      // Update state
      state <= next_state;

      // In ROLLING state: update counter on button press; latch last value on release
      if (state == ROLLING) begin
        if (button)
          counter <= (counter == 3'd6) ? 3'd1 : counter + 1;
        else
          dice_value <= counter;  // Latch the last value when button is released
      end
      // In IDLE state: if button is pressed, prepare for a new roll by setting dice_value to 1;
      // otherwise, hold the current dice_value.
      else begin  // state == IDLE
        if (button)
          dice_value <= 3'd1;
        else
          dice_value <= dice_value;
      end
    end
  end

endmodule