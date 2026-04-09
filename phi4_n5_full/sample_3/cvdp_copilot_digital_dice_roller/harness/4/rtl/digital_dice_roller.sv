module digital_dice_roller #(
    parameter int DICE_MAX  = 6,                    // Maximum dice value per die
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1,  // Bit width to represent dice value [1, DICE_MAX]
    parameter int NUM_DICE  = 2                      // Number of dice to roll simultaneously
) (
    input  wire clk,
    input  wire reset,  // Active LOW asynchronous reset
    input  wire button,
    output reg [NUM_DICE*BIT_WIDTH-1:0] dice_values
);

  // State encoding for the FSM
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;

  // Arrays to hold each dice's counter and its 16-bit LFSR random seed
  reg [BIT_WIDTH-1:0] counter [0:NUM_DICE-1];
  reg [15:0] random_seed [0:NUM_DICE-1];

  //-------------------------------------------------------------------------
  // FSM: Synchronous state transition on posedge clk or asynchronous reset
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  //-------------------------------------------------------------------------
  // Next state logic (combinational)
  // Transitions:
  //   IDLE   -> ROLLING when button is HIGH
  //   ROLLING-> IDLE   when button is LOW
  //-------------------------------------------------------------------------
  always_comb begin
    next_state = current_state;
    case (current_state)
      IDLE:   if (button) next_state = ROLLING;
      ROLLING: if (!button) next_state = IDLE;
    endcase
  end

  //-------------------------------------------------------------------------
  // Dice counters and LFSR update
  // In reset: initialize each dice counter to 1 and assign a unique 16-bit seed.
  // In ROLLING state, update each dice's LFSR and compute its counter value as:
  //    counter[i] = (random_seed[i] % DICE_MAX) + 1
  // The LFSR follows the polynomial: x^16 + x^5 + x^4 + x^3 + 1
  // Feedback bit = random_seed[i][15] XOR random_seed[i][4] XOR random_seed[i][3] XOR 1
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      for (int i = 0; i < NUM_DICE; i++) begin
         // Initialize with a unique seed (e.g., 1, 2, 3, …)
         random_seed[i] <= i + 1;
         counter[i]     <= 1;
      end
      dice_values <= '0;
    end else begin
      if (current_state == ROLLING) begin
         for (int i = 0; i < NUM_DICE; i++) begin
            // Compute the new feedback bit for the 16-bit LFSR
            logic new_bit;
            new_bit = random_seed[i][15] ^ random_seed[i][4] ^ random_seed[i][3] ^ 1;
            // Shift left and insert new_bit at LSB position
            random_seed[i] <= { new_bit, random_seed[i][15:1] };
            // Generate dice counter value in the range [1, DICE_MAX]
            counter[i] <= (random_seed[i] % DICE_MAX) + 1;
         end
      end
      // When in IDLE state, dice counters remain unchanged.
    end
  end

  //-------------------------------------------------------------------------
  // Output Latching: Flatten the dice counter values into dice_values bus.
  // Each dice occupies BIT_WIDTH bits. For example, with NUM_DICE = 2 and BIT_WIDTH = 3:
  //    Dice 1 = dice_values[5:3]
  //    Dice 2 = dice_values[2:0]
  // Latch the counters into dice_values when FSM is in IDLE.
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      dice_values <= '0;
    end else if (current_state == IDLE) begin
      logic [NUM_DICE*BIT_WIDTH-1:0] temp;
      temp = '0;
      // Concatenate each dice's counter into a flattened bus.
      // The most significant dice occupies the highest bits.
      for (int i = NUM_DICE-1; i >= 0; i--) begin
         temp = { temp[ (i+1)*BIT_WIDTH-1 : i*BIT_WIDTH ], counter[i] };
      end
      dice_values <= temp;
    end
  end

endmodule