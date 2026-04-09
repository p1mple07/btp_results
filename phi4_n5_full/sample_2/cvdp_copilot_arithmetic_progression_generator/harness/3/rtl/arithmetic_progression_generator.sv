module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,            // Width of the input data
    parameter SEQUENCE_LENGTH = 10         // Number of terms in the progression
)(
    input  logic clk,                      // Clock signal
    input  logic resetn,                   // Active-low reset
    input  logic enable,                   // Enable signal for the generator
    input  logic [DATA_WIDTH-1:0] start_val, // Start value of the sequence
    input  logic [DATA_WIDTH-1:0] step_size, // Step size of the sequence
    output logic [WIDTH_OUT_VAL-1:0] out_val, // Current value of the sequence
    output logic done                      // High when sequence generation is complete
);

  // Local parameter definition: calculate output width to avoid overflow.
  // Worst-case maximum value is: start_val + (SEQUENCE_LENGTH-1)*step_size.
  // Assuming worst-case inputs (max values), we use:
  //   max_possible = SEQUENCE_LENGTH * (2**DATA_WIDTH - 1)
  // and then WIDTH_OUT_VAL = $clog2(max_possible + 1)
  parameter WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH * (2**DATA_WIDTH - 1) + 1);

  // Internal signals
  logic [WIDTH_OUT_VAL-1:0] current_val;  // Register to hold the current value
  logic [$clog2(SEQUENCE_LENGTH)-1:0] counter;  // Counter to track sequence length

  // Procedural block: on positive edge of clock or active-low reset
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      // On reset, initialize current_val to start_val, counter to 0, and clear done.
      current_val <= start_val;
      counter     <= 0;
      done        <= 1'b0;
    end
    else if (enable) begin
      if (!done) begin
        // Update the arithmetic progression only if not done.
        // When counter reaches SEQUENCE_LENGTH-1, generate the final term and assert done.
        if (counter == SEQUENCE_LENGTH - 1) begin
          current_val <= current_val + step_size;
          done        <= 1'b1;
        end
        else begin
          current_val <= current_val + step_size;
          counter     <= counter + 1;
        end
      end
      // If done is asserted, simply hold the state.
    end
  end

  // Combinational assignment: output value is the current value.
  assign out_val = current_val;

endmodule