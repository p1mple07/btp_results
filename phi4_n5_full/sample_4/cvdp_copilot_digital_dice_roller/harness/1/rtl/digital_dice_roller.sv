module digital_dice_roller(
  input  logic         clk,
  input  logic         reset_n,
  input  logic         button,
  output logic [2:0]   dice_value
);

  // Define FSM states
  typedef enum logic [1:0] {
    IDLE  = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;

  // Internal counter to hold dice value (1 to 6)
  logic [2:0] counter;

  // Next state combinational logic
  always_comb begin
    next_state = current_state;
    case (current_state)
      IDLE: begin
        if (button)
          next_state = ROLLING;
      end
      ROLLING: begin
        if (!button)
          next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end

  // Sequential block: update state, counter, and output
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      current_state  <= IDLE;
      counter        <= 3'b0;   // On reset, counter is 0 (dice_value = 000)
      dice_value     <= 3'b0;
    end else begin
      current_state <= next_state;
      
      // When in ROLLING state and button is HIGH, increment the counter
      if (current_state == ROLLING && button) begin
        if (counter == 3'b110) // If counter == 6
          counter <= 3'b001;  // Roll over to 1
        else
          counter <= counter + 1;
      end
      
      // Output assignment: when in ROLLING, update dice_value to counter;
      // when in IDLE, hold the last dice value.
      if (current_state == ROLLING)
        dice_value <= counter;
      else
        dice_value <= dice_value;
    end
  end

endmodule