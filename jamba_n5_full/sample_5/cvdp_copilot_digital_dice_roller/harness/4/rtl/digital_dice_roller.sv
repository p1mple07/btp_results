module digital_dice_roller (#(parameter int DICE_MAX=6, int NUM_DICE=2));

  localparam int MAX_BITS = $clog2(DICE_MAX) + 1;

  // Parameters
  parameter int NUM_DICE = 2;
  parameter int BIT_WIDTH = MAX_BITS;

  // Counters and seeds
  integer [NUM_DICE-1:0] counters;
  integer [NUM_DICE-1:0] seeds;

  // States
  typedef enum logic [1:0] {
    IDLE,
    ROLLING
  } state_t;

  state_t current_state, next_state;

  // Always blocks
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      current_state <= IDLE;
      counters <= 1;
      seeds <= 0;
      dice_values <= 0;
    end else begin
      current_state <= next_state;
    end
  end

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

  // Combinational logic for each die
  always_comb begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (button) next_state = ROLLING;
      end

      ROLLING: begin
        // For each die, increment the counter, apply LFSR, clamp
        for (int i=0; i < NUM_DICE; i=i+1) begin
          counters[i] = (counters[i] + 1) & (~counters[i+1]);
          seeds[i] = (seeds[i] + 1) & (~seeds[i+1]);
        end
      end
    endcase
  end

  // Output: flatten all dice values
  assign dice_values = { for (int i=0; i < NUM_DICE; i=i+1) dice_values[((NUM_DICE-1)*BIT_WIDTH) + i*BIT_WIDTH : (NUM_DICE-1)*BIT_WIDTH + i*BIT_WIDTH + BIT_WIDTH - 1] };

endmodule
