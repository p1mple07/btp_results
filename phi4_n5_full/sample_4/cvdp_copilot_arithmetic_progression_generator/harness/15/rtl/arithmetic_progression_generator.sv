module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,
    parameter SEQUENCE_LENGTH = 10
)(
    input  logic clk,
    input  logic resetn,
    input  logic enable,
    input  logic [DATA_WIDTH-1:0] start_val,
    input  logic [DATA_WIDTH-1:0] step_size,
    output logic [((SEQUENCE_LENGTH == 0) ? DATA_WIDTH : ($clog2(SEQUENCE_LENGTH) + DATA_WIDTH))-1:0] out_val,
    output logic done
);

  // Local parameter definition
  // If SEQUENCE_LENGTH is zero, we simply use DATA_WIDTH for out_val;
  // otherwise, we add the counter width to DATA_WIDTH.
  localparam WIDTH_OUT_VAL = (SEQUENCE_LENGTH == 0) ? DATA_WIDTH : ($clog2(SEQUENCE_LENGTH) + DATA_WIDTH);

  // Internal signals
  logic [WIDTH_OUT_VAL-1:0] current_val;
  // For the counter, if SEQUENCE_LENGTH==0, a 1-bit wide register is sufficient.
  logic [((SEQUENCE_LENGTH == 0) ? 1 : $clog2(SEQUENCE_LENGTH)) - 1:0] counter;

  // Procedural block
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      current_val <= 0;
      counter     <= 0;
      done        <= 1'b0;
    end
    else if (enable) begin
      // Only perform arithmetic progression when SEQUENCE_LENGTH is nonzero.
      if (SEQUENCE_LENGTH != 0) begin
        if (!done) begin
          if (counter == 0)
            current_val <= start_val;  // Initialize with start value
          else
            current_val <= current_val + step_size;  // Compute next term

          if (counter < SEQUENCE_LENGTH - 1)
            counter <= counter + 1;  // Increment counter
          else
            done <= 1'b1;  // Mark completion
        end
      end
      // When SEQUENCE_LENGTH==0, no updates occur; current_val and done remain in reset state.
    end
  end

  // Combinational assignment
  assign out_val = current_val;

endmodule