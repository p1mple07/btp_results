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
  // Calculate WIDTH_OUT_VAL to handle overflow
  parameter WIDTH_OUT_VAL = DATA_WIDTH + $clog2(SEQUENCE_LENGTH);

  // Internal state variables
  logic [WIDTH_OUT_VAL-1:0] current_val;
  logic [$clog2(SEQUENCE_LENGTH)-1:0] counter;

  // Procedural block
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      current_val <= 0;
      counter <= 0;
      done <= 1'b0;
    else if (enable) begin
      if (!done) begin
        current_val <= current_val + step_size;
        counter <= counter + 1;
      else begin
        done <= 1'b1;
      end
    end
  end
endmodule