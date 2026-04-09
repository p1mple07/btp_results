module digital_dice_roller #(
    parameter int DICE_MAX  = 6,                    // Maximum dice value per die
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1, // Bit width to represent dice values [1, DICE_MAX]
    parameter int NUM_DICE  = 2                     // Number of dice to roll simultaneously
) (
    input  wire clk,
    input  wire reset,  // Active LOW asynchronous reset
    input  wire button,
    output reg [(NUM_DICE*BIT_WIDTH)-1:0] dice_values
);

  // State encoding
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;

  // Arrays for dice counters and random seeds (16-bit LFSR for each dice)
  reg [BIT_WIDTH-1:0] dice_counter [0:NUM_DICE-1];
  reg [15:0] random_seed [0:NUM_DICE-1];

  // Next state logic (combinational)
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
    endcase
  end

  // Sequential logic: state update, LFSR update, counter update, and output latching
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Asynchronous reset: initialize state, assign unique random seeds, set dice counters to 1,
      // and latch dice_values from dice_counter values.
      current_state <= IDLE;
      for (int i = 0; i < NUM_DICE; i++) begin
        random_seed[i]   <= i + 1;  // Unique seed initialization (e.g., Dice 1: 1, Dice 2: 2, ...)
        dice_counter[i]  <= 1;
      end
      for (int i = 0; i < NUM_DICE; i++) begin
        dice_values[i*BIT_WIDTH +: BIT_WIDTH] = dice_counter[i];
      end
    end else begin
      // In ROLLING state, update each dice's LFSR and compute its counter value.
      if (current_state == ROLLING) begin
        for (int i = 0; i < NUM_DICE; i++) begin
          // LFSR update using the polynomial: x^16 + x^5 + x^4 + x^3 + 1
          // Feedback is the XOR of bit[15], bit[5], bit[4], bit[3], and bit[0]
          bit feedback;
          feedback = random_seed[i][15] ^ random_seed[i][5] ^ random_seed[i][4] ^ random_seed[i][3] ^ random_seed[i][0];
          random_seed[i] <= {random_seed[i][14:0], feedback};
          // Compute dice value in the range [1, DICE_MAX]
          dice_counter[i] <= ((random_seed[i] % DICE_MAX) + 1);
        end
      end

      // Update FSM state based on combinational next_state logic
      current_state <= next_state;

      // When transitioning to IDLE, latch the current dice_counter values into the flattened output
      if (next_state == IDLE) begin
        for (int i = 0; i < NUM_DICE; i++) begin
          dice_values[i*BIT_WIDTH +: BIT_WIDTH] = dice_counter[i];
        end
      end
    end
  end

endmodule