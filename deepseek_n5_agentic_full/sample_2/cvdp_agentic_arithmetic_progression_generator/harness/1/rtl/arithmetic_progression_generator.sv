module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,
    parameter SEQUENCE_LENGTH = 10
)(
    clk,
    resetn,
    enable,
    start_val,
    step_size,
    out_val,
    done
);
  // Calculate minimum width needed to represent final value including start_val and SEQUENCE_LENGTH * step_size
  localparam WIDTH_OUT_VAL = max($clog2(SEQUENCE_LENGTH) + DATA_WIDTH, $clog2(start_val) + DATA_WIDTH + $clog2(step_size));

  // Check for invalid sequence length
  if (SEQUENCE_LENGTH <= 0)
    done <= 1;
    return;

  // ... rest of the code remains unchanged ...