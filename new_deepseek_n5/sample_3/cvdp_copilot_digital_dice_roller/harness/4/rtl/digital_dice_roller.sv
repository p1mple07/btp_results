module digital_dice_roller #(
    parameter int DICE_MAX  = 6,
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1,
    parameter int NUM_DICE = 2
) (
    input wire clk,
    input wire reset,
    input wire dice_count,
    input wire button,
    output reg [BIT_WIDTH-1:0]^dice_values
);

  // State encoding
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;
  reg [BIT_WIDTH-1:0] dice_values;

  // State transition and asynchronous reset logic (sequential)
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      current_state <= IDLE;
      dice_values <= 1;
    end else begin
      current_state <= next_state;
    end
  end

  // Next state logic and counter increment (combinational)
  always_comb begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (dice_count & button) next_state = ROLLING;
      end

      ROLLING: begin
        if (!(dice_count & button)) next_state = IDLE;
      end
    endcase
  end

  // Counter logic to simulate rolling dice values from 1 to DICE_MAX
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      dice_values <= 1;
    end else if (current_state == ROLLING) begin
      if (dice_values == DICE_MAX) dice_values <= 1;
      else dice_values <= dice_values + 1;
    end else if (current_state == IDLE) begin
      dice_values <= 1;
    end
  end
endmodule