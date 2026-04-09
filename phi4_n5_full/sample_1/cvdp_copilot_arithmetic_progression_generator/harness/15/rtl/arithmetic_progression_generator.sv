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

  // Define the width for out_val. When SEQUENCE_LENGTH==0, use DATA_WIDTH only.
  localparam WIDTH_OUT_VAL = (SEQUENCE_LENGTH == 0) ? DATA_WIDTH : ($clog2(SEQUENCE_LENGTH) + DATA_WIDTH);

  // Generate two behavioral versions based on SEQUENCE_LENGTH.
  generate
    if (SEQUENCE_LENGTH == 0) begin : no_sequence
      // When no sequence is requested, simply drive outputs to their reset values.
      assign out_val = {WIDTH_OUT_VAL{1'b0}};
      assign done    = 1'b0;
    end else begin : sequence
      // Local signals for sequence generation.
      logic [WIDTH_OUT_VAL-1:0] current_val;
      localparam COUNTER_WIDTH = $clog2(SEQUENCE_LENGTH);
      logic [COUNTER_WIDTH-1:0] counter;

      // Sequential process to generate the arithmetic progression.
      always_ff @(posedge clk or negedge resetn) begin
          if (!resetn) begin
              current_val <= 0;
              counter     <= 0;
              done        <= 1'b0;
          end else if (enable) begin
              if (!done) begin
                  if (counter == 0) begin
                      current_val <= start_val; // Initialize with start value
                  end else begin
                      current_val <= current_val + step_size; // Compute next term
                  end

                  if (counter < SEQUENCE_LENGTH - 1) begin
                      counter <= counter + 1; // Increment counter
                  end else begin
                      done <= 1'b1; // Mark completion
                  end
              end
          end
      end

      // Drive the output value.
      assign out_val = current_val;
    end
  endgenerate

endmodule