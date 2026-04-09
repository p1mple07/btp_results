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
  // Calculate WIDTH_OUT_VAL to prevent overflow
  parameter WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH) + DATA_WIDTH;

  // ... [rest of the code remains the same] ...

  // Procedural block
  always_ff @(posedge clk or negedge resetn) begin
      if (!resetn) begin
          current_val <= 0;
          counter <= 0;
          done <= 1'b0;
      end else if (enable) begin
          if (!done) begin
              counter <= counter + 1;
              current_val <= current_val + step_size;
          end else begin
              done <= 1;
          end
      end
  end
  // ... [rest of the code remains the same] ...