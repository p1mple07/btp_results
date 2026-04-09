module digital_dice_roller #(
    parameter int DICE_MAX  = 6,                    // Maximum dice value
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1, // Bit width to represent dice value
    parameter int NUM_DICE = 2                     // Number of dice to roll simultaneously
) (
    input wire clk,
    input wire reset,                           // Asynchronous reset signal
    input wire button,
    output reg [(NUM_DICE-1)*BIT_WIDTH-1:0] dice_values
);

  // State encoding
  typedef enum logic [(NUM_DICE-1):0] {
    IDLE = {2'b00, 2'b00},
    ROLLING = {2'b01, 2'b01, ..., 2'b01} // Repeat for each dice
  } state_t;

  state_t current_state, next_state;
  reg [(NUM_DICE-1)*BIT_WIDTH-1:0] counter;  // Counter to represent dice values
  logic [15:0] random_seed[NUM_DICE-1];       // Random seeds for each dice

  // State transition and asynchronous reset logic (sequential)
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset to initial values when async_reset is asserted
      current_state <= IDLE;
      for (int i = 0; i < NUM_DICE; i++) begin
        counter[i] <= 1;
        random_seed[i] <= NUM_DICE - 1 - i;
      end
      dice_values <= {(NUM_DICE-1)*BIT_WIDTH-1:0{1'b0}};
    end else begin
      current_state <= next_state;
    end
  end

  // Next state logic and counter increment (combinational)
  always_comb begin
    next_state = current_state;

    // Update random seed for each dice based on LFSR
    case (current_state)
      IDLE: begin
        for (int i = 0; i < NUM_DICE; i++) begin
          if (random_seed[i] > 0) begin
            random_seed[i] = (random_seed[i] + 1) & (~0); // Simple LFSR: XOR with 1
          end else begin
            random_seed[i] = NUM_DICE - 1 - i; // Reset seed if it overflows
          end
        end
      end

      ROLLING: begin
        for (int i = 0; i < NUM_DICE; i++) begin
          if (counter[i] >= DICE_MAX) begin
            counter[i] <= 1; // Reset to 1 after reaching DICE_MAX
          end else begin
            counter[i] <= counter[i] + 1;
          end
        end
      end
    endcase

    // Counter logic to simulate rolling dice values from 1 to DICE_MAX
    always_ff @(posedge clk or negedge reset) begin
      if (!reset) begin
        dice_values <= {(NUM_DICE-1)*BIT_WIDTH-1:0{1'b0}};
      end else if (current_state == ROLLING) begin
        for (int i = 0; i < NUM_DICE; i++) begin
          dice_values[i*BIT_WIDTH:(i+1)*BIT_WIDTH-1] <= {counter[i] % DICE_MAX + 1, NUM_DICE-1'b0};
        end
      end else if (current_state == IDLE) begin
        for (int i = 0; i < NUM_DICE; i++) begin
          dice_values[i*BIT_WIDTH:(i+1)*BIT_WIDTH-1] <= counter[i];
        end
      end
    end
  end
endmodule
 module digital_dice_roller #(
    parameter int DICE_MAX  = 6,                    // Maximum dice value
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1, // Bit width to represent dice value
    parameter int NUM_DICE = 2                     // Number of dice to roll simultaneously
) (
    input wire clk,
    input wire reset,                           // Asynchronous reset signal
    input wire button,
    output reg [(NUM_DICE-1)*BIT_WIDTH-1:0] dice_values
);

  // State encoding
  typedef enum logic [(NUM_DICE-1):0] {
    IDLE = {2'b00},
    ROLLING = {2'b01} // Repeat for each dice
  } state_t;

  state_t current_state, next_state;
  reg [(NUM_DICE-1)*BIT_WIDTH-1:0] counter;  // Counter to represent dice values
  logic [15:0] random_seed[NUM_DICE-1];       // Random seeds for each dice

  // State transition and asynchronous reset logic (sequential)
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset to initial values when async_reset is asserted
      current_state <= IDLE;
      for (int i = 0; i < NUM_DICE; i++) begin
        counter[i] <= 1;
        random_seed[i] <= NUM_DICE - 1 - i;
      end
      dice_values <= {(NUM_DICE-1)*BIT_WIDTH-1:0{1'b0}};
    end else begin
      current_state <= next_state;
    end
  end

  // Next state logic and counter increment (combinational)
  always_comb begin
    next_state = current_state;

    // Update random seed for each dice based on LFSR
    case (current_state)
      IDLE: begin
        for (int i = 0; i < NUM_DICE; i++) begin
          if (random_seed[i] > 0) begin
            random_seed[i] = (random_seed[i] + 1) & (~0); // Simple LFSR: XOR with 1
          end else begin
            random_seed[i] = NUM_DICE - 1 - i; // Reset seed if it overflows
          end
        end
      end

      ROLLING: begin
        for (int i = 0; i < NUM_DICE; i++) begin
          if (counter[i] >= DICE_MAX) begin
            counter[i] <= 1; // Reset to 1 after reaching DICE_MAX
          end else begin
            counter[i] <= counter[i] + 1;
          end
        end
      end
    endcase

    // Counter logic to simulate rolling dice values from 1 to DICE_MAX
    always_ff @(posedge clk or negedge reset) begin
      if (!reset) begin
        dice_values <= {(NUM_DICE-1)*BIT_WIDTH-1:0{1'b0}};
      end else if (current_state == ROLLING) begin
        for (int i = 0; i < NUM_DICE; i++) begin
          dice_values[i*BIT_WIDTH:(i+1)*BIT_WIDTH-1] <= (counter[i] % DICE_MAX + 1) << BIT_WIDTH*i;
        end
      end else if (current_state == IDLE) begin
        for (int i = 0; i < NUM_DICE; i++) begin
          dice_values[i*BIT_WIDTH:(i+1)*BIT_WIDTH-1] <= counter[i];
        end
      end
    end
  end
endmodule