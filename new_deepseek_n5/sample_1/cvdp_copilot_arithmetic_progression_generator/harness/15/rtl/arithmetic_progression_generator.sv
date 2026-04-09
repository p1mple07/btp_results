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
  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------
    if (SEQUENCE_LENGTH == 0) begin
        done <= 0;
        out_val <= 0;
        return;
    end
    localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH) + DATA_WIDTH; // Bit width of out_val to prevent overflow
  // ... (rest of the code remains unchanged)