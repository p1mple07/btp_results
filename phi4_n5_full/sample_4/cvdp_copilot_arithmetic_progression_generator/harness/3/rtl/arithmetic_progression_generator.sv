module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,           // Width of the input data
    parameter SEQUENCE_LENGTH = 10       // Number of terms in the progression
)(
    input  logic         clk,            // Clock signal
    input  logic         resetn,         // Active-low reset
    input  logic         enable,         // Enable signal for the generator
    input  logic [DATA_WIDTH-1:0] start_val, // Start value of the sequence
    input  logic [DATA_WIDTH-1:0] step_size, // Step size of the sequence
    output logic [WIDTH_OUT_VAL-1:0] out_val, // Current value of the sequence
    output logic         done            // High when sequence generation is complete
);

  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------
  // Calculate the minimum bit width required to hold the maximum possible term:
  // Maximum term = start_val + (SEQUENCE_LENGTH-1)*step_size.
  // In worst-case, start_val and step_size can each be (2**DATA_WIDTH - 1),
  // so maximum term = SEQUENCE_LENGTH*(2**DATA_WIDTH - 1).
  // We add 1 and take the clog2 to get the required width.
  parameter WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH * ((2**DATA_WIDTH) - 1) + 1);

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------

  // ----------------------------------------
  // - Internal signals
  // ----------------------------------------
  logic [WIDTH_OUT_VAL-1:0] current_val;  // Register to hold the current value
  logic [$clog2(SEQUENCE_LENGTH)-1:0] counter;  // Counter to track sequence length

  // ----------------------------------------
  // - Procedural block
  // ----------------------------------------
  // Note: The module has a 1-cycle latency. When enable is high, the first output
  // is the value loaded from start_val (set at reset). Subsequent updates add step_size.
  // If enable goes low, the state (current_val and counter) is held.
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      // On reset, initialize current_val with start_val, counter to 0, and clear done.
      current_val <= start_val;
      counter     <= 0;
      done        <= 1'b0;
    end else if (enable) begin
      if (counter == 0) begin
        // First cycle after enable: hold the value (start_val) and increment counter.
        counter <= counter + 1;
      end else if (counter < SEQUENCE_LENGTH - 1) begin
        // Normal update: add step_size and increment counter.
        current_val <= current_val + step_size;
        counter     <= counter + 1;
      end else begin
        // Last term: update current_val and assert done.
        current_val <= current_val + step_size;
        done        <= 1'b1;
      end
    end
  end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
  assign out_val = current_val;

endmodule