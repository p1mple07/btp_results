
module digital_dice_roller #(
    parameter int DICE_MAX  = 6,                    // Maximum dice value
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1, // Bit width to represent dice value
    parameter int NUM_DICE = 2                    // Number of dice to roll simultaneously
) (
    input wire clk,
    input wire reset,  // Asynchronous reset signal
    input wire button,
    output reg [NUM_DICE * BIT_WIDTH - 1:0] dice_values // Flattened array for dice values
);

  // State encoding
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;
  reg [BIT_WIDTH-1:0] counter[NUM_DICE-1:0]; // Counter to represent dice values for each dice

  // State transition and asynchronous reset logic (sequential)
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset all dice counters and transitions to IDLE state
      current_state <= IDLE;
      for (int i = 0; i < NUM_DICE; i++) begin
        counter[i] <= 1;
      end
      dice_values <= {1'b0, counter[0], counter[1], 1'b0}; // Flattened array initialization
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
      // Reset all dice counters and transitions to IDLE state
      current_state <= IDLE;
      for (int i = 0; i < NUM_DICE; i++) begin
        counter[i] <= 1;
      end
      dice_values <= {1'b0, counter[0], counter[1], 1'b0}; // Flattened array initialization
    end else if (current_state == ROLLING) begin
      for (int i = 0; i < NUM_DICE; i++) begin
        if (counter[i] == DICE_MAX) counter[i] <= 1;  // Reset to 1 after reaching DICE_MAX
        else counter[i] <= counter[i] + 1;
      end
      // Latch the final values for each dice into the flattened array
      dice_values <= {counter[0], counter[1], 1'b0};
    end else if (current_state == IDLE) begin
      // Latch the last rolled values into the flattened array
      dice_values <= {counter[0], counter[1], 1'b0};
    end
  end
endmodule
