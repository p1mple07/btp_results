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
  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------

  // Calculate WIDTH_OUT_VAL to handle the out_val bit width to avoid overflow.
  localparam WIDTH_OUT_VAL = 1;
  if (SEQUENCE_LENGTH > 0 && step_size > 0) begin
      localparam max_val = start_val + (SEQUENCE_LENGTH - 1) * step_size;
      WIDTH_OUT_VAL = (max_val + 1).bit_length();
  end

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------
  input logic clk;                          // Clock signal
  input logic resetn;                       // Active-low reset
  input logic enable;                       // Enable signal for the generator
  input logic [DATA_WIDTH-1:0] start_val;   // Start value of the sequence
  input logic [DATA_WIDTH-1:0] step_size;   // Step size of the sequence
  output logic [WIDTH_OUT_VAL-1:0] out_val; // Current value of the sequence
  output logic done;                        // High when sequence generation is complete

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
          counter <= 0;
          done <= 1'b0;
      end else if (enable) begin
          if (!done) begin
              if (sequencer_active) begin
                  current_val <= current_val + step_size;
                  if (current_val >= start_val + (SEQUENCE_LENGTH - 1) * step_size) begin
                      done <= 1'b1;
                  end
              end
          end
      end
  end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
  assign out_val = current_val;
endmodule
