module digital_dice_roller #(
    parameter int DICE_MAX  = 6,
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1,
    parameter int NUM_DICE = 2
) (
    input wire clk,
    input wire reset,  // Asynchronous reset signal
    input wire button,
    input int NUM_DICE,
    output reg [BIT_WIDTH-1:0] dice_values
);

  // State encoding
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state[NUM_DICE], next_state[NUM_DICE];
  reg [BIT_WIDTH-1:0] counter[NUM_DICE];
  // Counter to represent dice values
  reg [BIT_WIDTH-1:0] dice_value[NUM_DICE];

  // State transition and asynchronous reset logic (sequential)
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset to initial values when async_reset is asserted
      current_state <= IDLE;
      counter <= 1;
      dice_value <= 1;
    end else begin
      current_state <= next_state;
    end
  end

  // Next state logic and counter increment (combinational)
  always_comb begin
    next_state = current_state;

    case (current_state[0])
      IDLE: begin
        if (button) next_state[0] = ROLLING;
      end

      ROLLING: begin
        if (!button) next_state[0] = IDLE;
      end
    endcase

    case (current_state[1])
      IDLE: begin
        if (button) next_state[1] = ROLLING;
      end

      ROLLING: begin
        if (!button) next_state[1] = IDLE;
      end
    endcase
  end

  // Counter logic to simulate rolling dice values from 1 to DICE_MAX
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset counter and dice value when async_reset is asserted
      counter <= 1;
      dice_value <= 1;
    end else if (current_state[0] == ROLLING) begin
      if (counter[0] == DICE_MAX) counter[0] <= 1;  // Reset to 1 after reaching DICE_MAX
      else counter[0] <= counter[0] + 1;
    end else if (current_state[0] == IDLE) begin
      dice_value[0] <= counter[0];  // Latch the final value
    end else if (current_state[1] == ROLLING) begin
      if (counter[1] == DICE_MAX) counter[1] <= 1;
      else counter[1] <= counter[1] + 1;
    end else if (current_state[1] == IDLE) begin
      dice_value[1] <= counter[1];
    end
  end
endmodule