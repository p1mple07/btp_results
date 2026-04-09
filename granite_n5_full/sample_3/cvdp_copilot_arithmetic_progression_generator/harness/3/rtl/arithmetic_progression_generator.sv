module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,  // Width of the input data
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
  // Insights:
  // - Use a localparam to define the maximum number of bits needed to represent the output value without overflowing. This can be calculated as log2 of the maximum possible value divided by the bit width of the output value.
  // - Initialize the counter and output value registers to ensure they are properly initialized in case the reset signal is asserted.
  // - Use an always_ff block to update the counter and output value registers based on the enable signal and the clock signal.
  // - Inside the always_ff block, check if the enable signal is high and the output value register is not full. If both conditions are true, update the output value register with the computed value. Otherwise, set the output value register to 0.
  // - Check if the enable signal is low and the output value register is not empty. If both conditions are true, set the done signal to 1. Otherwise, leave it unchanged.
  // - Add a combinational assignment to connect the output value register to the out_val port.
  // - Use a comment to describe the purpose of the WIDTH_OUT_VAL parameter.
  // - Add a comment to explain how the sequence generation is paused when enable goes low.
  // - Use a comment to indicate that the counter and output value registers should be initialized to 0 before enabling the module.

  localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH);

  // Registers
  logic [WIDTH_OUT_VAL-1:0] current_val;
  logic [$clog2(SEQUENCE_LENGTH)-1:0] counter;

  // Inputs
  input logic clk;                          // Clock signal
  input logic resetn;                       // Active-low reset
  input logic enable;                       // Enable signal for the generator
  input logic [DATA_WIDTH-1:0] start_val;   // Start value of the sequence
  input logic [DATA_WIDTH-1:0] step_size;   // Step size of the sequence
  output logic [WIDTH_OUT_VAL-1:0] out_val; // Current value of the sequence
  output logic done;                        // High when sequence generation is complete

  // Computations
  assign current_val = enable? (counter < SEQUENCE_LENGTH? start_val + counter * step_size : 0) : 0;
  assign done = enable?!counter : done;

  // Counter
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      current_val <= 0;
      counter <= 0;
      done <= 1'b0;
    end else if (enable &&!done) begin
      if (counter < SEQUENCE_LENGTH) begin
        current_val <= start_val + counter * step_size;
      end else begin
        current_val <= 0;
      end
      counter <= counter + 1;
    end else if (enable && done) begin
      done <= 1'b0;
    end
  end

endmodule