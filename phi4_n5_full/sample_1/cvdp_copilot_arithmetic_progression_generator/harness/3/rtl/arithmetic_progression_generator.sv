module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,        // Width of the input data
    parameter SEQUENCE_LENGTH = 10     // Number of terms in the progression
)(
    input logic clk,                   // Clock signal
    input logic resetn,                // Active-low reset
    input logic enable,                // Enable signal for the generator
    input logic [DATA_WIDTH-1:0] start_val, // Start value of the sequence
    input logic [DATA_WIDTH-1:0] step_size, // Step size of the sequence
    output logic [WIDTH_OUT_VAL-1:0] out_val, // Current value of the sequence
    output logic done                  // High when sequence generation is complete
);

  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------
  // Calculate WIDTH_OUT_VAL to avoid overflow.
  // Worst-case maximum value = start_val + (SEQUENCE_LENGTH - 1)*step_size.
  // In worst-case, start_val and step_size are maximum (2^DATA_WIDTH - 1),
  // so the maximum value is less than SEQUENCE_LENGTH * 2**DATA_WIDTH.
  // Therefore, we need DATA_WIDTH + $clog2(SEQUENCE_LENGTH) bits.
  localparam WIDTH_OUT_VAL = DATA_WIDTH + $clog2(SEQUENCE_LENGTH);

  // ----------------------------------------
  // - Internal signals
  // ----------------------------------------
  logic [WIDTH_OUT_VAL-1:0] current_val;  // Register to hold the current value
  logic [$clog2(SEQUENCE_LENGTH)-1:0] counter;  // Counter to track sequence length

  // ----------------------------------------
  // - Procedural block
  // ----------------------------------------
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      current_val <= 0;
      counter     <= 0;
      done        <= 1'b0;
    end else if (enable) begin
      if (!done) begin
        // On first cycle, load start_val; otherwise, add step_size.
        if (counter == 0)
          current_val <= start_val;
        else
          current_val <= current_val + step_size;

        // If we have generated all terms, assert done.
        if (counter == SEQUENCE_LENGTH - 1)
          done <= 1'b1;
        else
          counter <= counter + 1;
      end else begin
        // Once done is asserted, maintain the final value.
      end
    end
  end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
  assign out_val = current_val;

endmodule