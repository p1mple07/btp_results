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

  localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH + 1);

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
                    // Insert code here to compute current_val 
                    // Make sure to use the correct width for the counter and current_val registers
                    // Avoid overflow by using a formula that handles overflow conditions
                end else begin
                    // Insert code here to assert the `done` signal when the sequence is complete
                end
            end
        end
    end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
    assign out_val = current_val;

endmodule