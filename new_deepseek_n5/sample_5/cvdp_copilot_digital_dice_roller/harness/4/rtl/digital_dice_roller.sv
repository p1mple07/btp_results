module digital_dice_roller #(
    parameter int DICE_MAX  = 6,
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1,
    parameter int NUM_DICE = 2
) (
    input wire clk,
    input wire reset,
    input wire button,
    input wire [NUM_DICE-1:0] dice_values,
    output reg [BIT_WIDTH-1:0] dice_value
);

  // State encoding
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;
  reg [BIT_WIDTH-1:0] [NUM_DICE-1:0] counter;  // Counter for each die
  reg [BIT_WIDTH-1:0] [NUM_DICE-1:0] dice_value;  // Dice values
  reg [16-1:0] [NUM_DICE-1:0] random_seed;  // Random seeds for each die

  // State transition and asynchronous reset logic (sequential)
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      current_state <= IDLE;
      [counter-1:0] <= 1;
      [dice_value-1:0] <= 1;
      random_seed <= [16-1:0] (1 << ($i)) for $i in 0[NUM_DICE-1];
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
      [counter-1:0] <= 1;
      [dice_value-1:0] <= 1;
      random_seed <= [16-1:0] (1 << ($i)) for $i in 0[NUM_DICE-1];
    end else if (current_state == ROLLING) begin
      if (counter[$i] == DICE_MAX) counter[$i] <= 1;  // Reset to 1 after reaching DICE_MAX
      else counter[$i] <= counter[$i] + 1;
    end else if (current_state == IDLE) begin
      [dice_value-1:0] <= [counter-1:0];
    end
  end
endmodule