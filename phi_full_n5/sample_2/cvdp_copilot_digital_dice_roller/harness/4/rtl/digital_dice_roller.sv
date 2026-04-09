module digital_dice_roller #(
    parameter int DICE_MAX  = 6,                    // Maximum dice value
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1, // Bit width to represent dice value
    parameter int NUM_DICE = 2                    // Number of dice to roll
) (
    input wire clk,
    input wire reset,  // Asynchronous reset signal
    input wire button,
    output reg [NUM_DICE * BIT_WIDTH - 1:0] dice_values // Flattened array for all dice values
);

  // State encoding
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;
  reg [BIT_WIDTH-1:0] counter[NUM_DICE-1:0];  // Array to represent dice values

  // State transition and asynchronous reset logic (sequential)
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset to initial values when async_reset is asserted
      current_state <= IDLE;
      for (int i = 0; i < NUM_DICE; i++) begin
        counter[i] <= (1 << BIT_WIDTH) - 1;
        dice_values[NUM_DICE * BIT_WIDTH - 1 - i*BIT_WIDTH] = (1 << BIT_WIDTH) - 1;
      end
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
      // Reset counters and dice values when async_reset is asserted
      for (int i = 0; i < NUM_DICE; i++) begin
        counter[i] <= (1 << BIT_WIDTH) - 1;
        dice_values[NUM_DICE * BIT_WIDTH - 1 - i*BIT_WIDTH] = (1 << BIT_WIDTH) - 1;
      end
    end else if (current_state == ROLLING) begin
      for (int i = 0; i < NUM_DICE; i++) begin
        if (counter[i] == DICE_MAX) counter[i] <= 1;  // Reset to 1 after reaching DICE_MAX
        else counter[i] <= counter[i] + 1;
      end
    end else if (current_state == IDLE) begin
      for (int i = 0; i < NUM_DICE; i++) begin
        dice_values[NUM_DICE * BIT_WIDTH - 1 - i*BIT_WIDTH] = counter[i];
      end
    end
  end
endmodule
