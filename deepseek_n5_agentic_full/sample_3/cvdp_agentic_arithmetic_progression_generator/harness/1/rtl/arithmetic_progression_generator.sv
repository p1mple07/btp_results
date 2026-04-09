module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,
    parameter SEQUENCE_LENGTH = 10
)();
  // ... existing parameters and types ...

  // Fixed Overflow Handling in out_val Calculation
  localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH) + DATA_WIDTH + 1; // Added +1 for overflow margin

  // Check for Sequence Length Zero
  if (SEQUENCE_LENGTH == 0) begin
      done <= 1'b0;
      current_val <= 0;
  end

  // ... rest of the code ...