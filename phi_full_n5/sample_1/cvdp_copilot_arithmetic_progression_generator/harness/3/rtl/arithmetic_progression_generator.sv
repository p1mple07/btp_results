module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,  // Width of the input data
    parameter SEQUENCE_LENGTH = 10 // Number of terms in the progression
)(
    input logic clk,
    input logic resetn,
    input logic enable,
    input logic [DATA_WIDTH-1:0] start_val,
    input logic [DATA_WIDTH-1:0] step_size,
    output logic [WIDTH_OUT_VAL-1:0] out_val, // Current value of the sequence
    output logic done                        // High when sequence generation is complete
);

  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------
  // Calculate parameter WIDTH_OUT_VAL to handle the out_val bit width to avoid overflow
  parameter WIDTH_OUT_VAL = DATA_WIDTH + $clog2(SEQUENCE_LENGTH);

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------

    // Interface definitions (already provided)

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
                // Compute current_val
                current_val <= current_val + step_size;
                counter <= counter + 1;
                // Check if sequence length counter has reached SEQUENCE_LENGTH
                if (counter == SEQUENCE_LENGTH) begin
                    done <= 1'b1;
                    // Set out_val to the last value generated
                    out_val <= current_val;
                end
            end
        end
    end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
    assign out_val = current_val;

endmodule
