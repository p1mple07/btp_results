module digital_dice_roller #(
    parameter int DICE_MAX  = 6,                    // Maximum dice value
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1,  // Bit width to represent dice value
    parameter int NUM_DICE  = 2                     // Number of dice to roll simultaneously
) (
    input  wire clk,
    input  wire reset,  // Asynchronous reset signal (active LOW)
    input  wire button,
    output reg [(NUM_DICE*BIT_WIDTH)-1:0] dice_values  // Flattened dice values output
);

  // State encoding
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;
  state_t prev_state; // To detect transition from ROLLING to IDLE

  // Arrays for dice counters, random seeds, and first update flags
  reg [BIT_WIDTH-1:0] counters [0:NUM_DICE-1];
  reg [15:0] random_seed [0:NUM_DICE-1];
  reg first_update [0:NUM_DICE-1];

  //-------------------------------------------------------------------------
  // State transition and asynchronous reset logic
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      current_state <= IDLE;
      prev_state    <= IDLE;
    end else begin
      prev_state    <= current_state;
      current_state <= next_state;
    end
  end

  //-------------------------------------------------------------------------
  // Next state logic
  //-------------------------------------------------------------------------
  always_comb begin
    next_state = current_state;
    if (current_state == IDLE) begin
      if (button)
        next_state = ROLLING;
    end else if (current_state == ROLLING) begin
      if (!button)
        next_state = IDLE;
    end
  end

  //-------------------------------------------------------------------------
  // Dice update logic: LFSR update, counter update, and dice value latching
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset: initialize all dice counters, assign unique random seeds,
      // and mark each dice for its first LFSR update.
      for (int i = 0; i < NUM_DICE; i++) begin
        counters[i]    <= 1;
        random_seed[i] <= i + 1;  // Unique seed initialization (Dice 1 = 1, Dice 2 = 2, etc.)
        first_update[i] <= 1;
      end
      // Latch initial dice values on output
      for (int i = 0; i < NUM_DICE; i++) begin
        dice_values[(i+1)*BIT_WIDTH - BIT_WIDTH +: BIT_WIDTH] <= 1;
      end
    end
    else if (current_state == ROLLING) begin
      // In ROLLING state, update each dice independently:
      // 1. Update the 16-bit LFSR using a shift‐left operation.
      //    For the very first update, the new bit is OR’ed with 1.
      //    Subsequent updates simply shift left.
      // 2. Generate the dice counter value as:
      //       counter = (random_seed % DICE_MAX) + 1
      for (int i = 0; i < NUM_DICE; i++) begin
        if (first_update[i]) begin
          random_seed[i] <= (random_seed[i] << 1) | 1;