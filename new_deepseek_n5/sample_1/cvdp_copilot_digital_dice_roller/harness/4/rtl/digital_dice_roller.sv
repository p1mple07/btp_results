module digital_dice_roller #(
    parameter int DICE_MAX  = 6,
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1,
    parameter int NUM_DICE = 2
) (
    input wire clk,
    input wire reset,  // Asynchronous reset signal
    input wire button,
    output reg [BIT_WIDTH-1:0] dice_values
);

  // State encoding
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;
  reg [BIT_WIDTH-1:0] counters[NUM_DICE];  // Array to hold each die's counter
  reg [BIT_WIDTH-1:0] dice_values;  // Output array

  // State transition and asynchronous reset logic (sequential)
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      current_state <= IDLE;
      counters = {1, 1, 1};  // Initialize all dice counters to 1
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
      counters = {1, 1, 1};  // Reset all dice counters to 1
      dice_values <= {0};  // Reset output
    end else if (current_state == ROLLING) begin
      for (int i = 0; i < NUM_DICE; i++) {
        if (counters[i] == DICE_MAX) {
          counters[i] <= 1;
        } else {
          counters[i] <= counters[i] + 1;
        }
      }
    end else if (current_state == IDLE) begin
      for (int i = 0; i < NUM_DICE; i++) {
        dice_values[i * BIT_WIDTH:(i * BIT_WIDTH)+BIT_WIDTH-1] <= 
          (counters[i] % DICE_MAX) + 1;
      }
    end
  end
endmodule