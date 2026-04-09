module digital_dice_roller #(
    parameter int DICE_MAX  = 6,                    // Maximum dice value
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1, // Bit width to represent dice value
    parameter int NUM_DICE = 2                    // Number of dice to roll simultaneously
) (
    input wire clk,
    input wire reset,  // Asynchronous reset signal
    input wire button,
    output reg [(NUM_DICE - 1) * BIT_WIDTH - 1:0] dice_values
);

  // State encoding
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;
  reg [BIT_WIDTH-1:0] counter[0:NUM_DICE - 1];  // Counter to represent dice values for each dice

  // Unique random seed initialization
  reg [15:0] random_seed[0:NUM_DICE - 1];

  // State transition and asynchronous reset logic (sequential)
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset to initial values when async_reset is asserted
      current_state <= IDLE;
      for (int i = 0; i < NUM_DICE; i++) begin
        counter[i] <= (1 << BIT_WIDTH) - 1; // Reset all counters to the maximum value
        random_seed[i] <= 16'h00000001 + (i - 1) * 16'h00000001; // Initialize unique seeds
      end
      dice_values <= (NUM_DICE * BIT_WIDTH - 1):0; // Latch current dice values
    end else begin
      current_state <= next_state;
    end
  end

  // Next state logic and counter increment (combinational)
  always_comb begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (button) next_state = ROLLING;
      end

      ROLLING: begin
        if (!button) next_state = IDLE;
      end
    endcase
  end

  // Counter logic to simulate rolling dice values from 1 to DICE_MAX
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset counter and dice value when async_reset is asserted
      for (int i = 0; i < NUM_DICE; i++) begin
        counter[i] <= (1 << BIT_WIDTH) - 1; // Reset counter to maximum value
      end
      dice_values <= (NUM_DICE * BIT_WIDTH - 1):0; // Latch current dice values
    end else if (current_state == ROLLING) begin
      for (int i = 0; i < NUM_DICE; i++) begin
        if (counter[i] == (DICE_MAX - 1)) counter[i] <= 0; // Reset counter if dice value reaches DICE_MAX
        else counter[i] <= counter[i] + 1; // Increment counter
      end
    end else if (current_state == IDLE) begin
      dice_values <= counter; // Latch the final values
    end
  end
endmodule
