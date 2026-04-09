module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,
    parameter SEQUENCE_LENGTH = 10 // Number of terms in the progression
)(
   clk,
    resetn,
    enable,
    start_val,
    step_size,
    out_val,
    done
);
  // Check if sequence length is zero and handle appropriately
  if (SEQUENCE_LENGTH == 0) begin
      current_val <= 0;
      out_val <= 0;
      done <= 1'b1;
      return;
  end

  // Calculate the minimum width needed to prevent overflow
  localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH) + DATA_WIDTH;

  // ... rest of the code remains unchanged ...