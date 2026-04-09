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

  // Guard against zero sequence length
  if (SEQUENCE_LENGTH == 0) begin
      out_val <= 0;
      done <= 1'b0;
      current_val <= 0;
      counter <= 0;
  end else begin
      // Original sequential generation logic
  end

  localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH) + DATA_WIDTH;

  assign out_val = current_val;

endmodule
