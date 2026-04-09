module arithmetic_progression_generator #(parameter DATA_WIDTH = 16, parameter SEQUENCE_LENGTH = 10, parameter WIDTH_OUT_VAL = DATA_WIDTH + $clog2(SEQUENCE_LENGTH) + 1)
(
    clk,
    resetn,
    enable,
    start_val,
    step_size,
    out_val,
    done
);
  // Local parameter definition
  parameter WIDTH_OUT_VAL = DATA_WIDTH + $clog2(SEQUENCE_LENGTH) + 1;

  // Internal signals
  logic [WIDTH_OUT_VAL-1:0] current_val;
  logic [$clog2(SEQUENCE_LENGTH)+1-1:0] counter;

  // Procedural block
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      current_val <= 0;
      counter <= 0;
      done <= 0;
    end else if (enable) begin
      if (!done) begin
        current_val <= current_val + step_size;
        current_val <= current_val & ((1 << $clog2(SEQUENCE_LENGTH)) - 1);
        counter <= counter + 1;
        if (counter == SEQUENCE_LENGTH) begin
          done <= 1;
        end
      end
    end
  end
endmodule