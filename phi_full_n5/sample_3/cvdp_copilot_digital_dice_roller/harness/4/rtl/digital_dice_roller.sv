
module digital_dice_roller #(
    parameter int DICE_MAX  = 6,                    // Maximum dice value
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1  // Bit width to represent dice value
) (
    input wire clk,
    input wire reset,  // Asynchronous reset signal
    input wire button,
    output reg [(NUM_DICE-1)*BIT_WIDTH-1:0] dice_values
);

  // State encoding
  typedef enum logic [(NUM_DICE-1):0] {
    IDLE = {2'b00, 2'b00, ... (NUM_DICE-2 times)}, // All dice in idle state
    ROLLING = {2'b01, 2'b01, ... (NUM_DICE-1 times)} // All dice in rolling state
  } state_t;

  state_t current_state, next_state;
  reg [(NUM_DICE-1)*BIT_WIDTH-1:0] counter;  // Counter to represent dice values

  // State transition and asynchronous reset logic (sequential)
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset to initial values when async_reset is asserted
      current_state <= IDLE;
      for (int i = 0; i < NUM_DICE; i++) begin
        counter[i*(BIT_WIDTH-1)+:BIT_WIDTH-1] <= 1;
      end
      dice_values <= {counter[(NUM_DICE-1)*(BIT_WIDTH-1)-1:0], counter[(NUM_DICE-2)*(BIT_WIDTH-1)-1:0], ... (NUM_DICE-1 times)};
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
        counter[i*(BIT_WIDTH-1)+:BIT_WIDTH-1] <= 1;
      end
      dice_values <= {counter[(NUM_DICE-1)*(BIT_WIDTH-1)-1:0], counter[(NUM_DICE-2)*(BIT_WIDTH-1)-1:0], ... (NUM_DICE-1 times)};
    end else if (current_state == ROLLING) begin
      for (int i = 0; i < NUM_DICE; i++) begin
        if (counter[i*(BIT_WIDTH-1)+:BIT_WIDTH-1] == DICE_MAX) begin
          counter[i*(BIT_WIDTH-1)+:BIT_WIDTH-1] <= 1;
        end else begin
          counter[i*(BIT_WIDTH-1)+:BIT_WIDTH-1] <= counter[i*(BIT_WIDTH-1)+:BIT_WIDTH-1] + 1;
        end
      end
      dice_values <= {counter[(NUM_DICE-1)*(BIT_WIDTH-1)-1:0], counter[(NUM_DICE-2)*(BIT_WIDTH-1)-1:0], ... (NUM_DICE-1 times)};
    end else if (current_state == IDLE) begin
      for (int i = 0; i < NUM_DICE; i++) begin
        dice_values[i*(BIT_WIDTH-1)+:BIT_WIDTH-1] <= counter[i*(BIT_WIDTH-1)+:BIT_WIDTH-1];
      end
    end
  end
endmodule
