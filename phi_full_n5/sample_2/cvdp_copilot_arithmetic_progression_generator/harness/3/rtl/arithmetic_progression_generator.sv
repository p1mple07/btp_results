module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,  // Width of the input data
    parameter SEQUENCE_LENGTH = 10 // Number of terms in the progression
)(
    input logic clk,                          // Clock signal
    input logic resetn,                       // Active-low reset
    input logic enable,                       // Enable signal for the generator
    input logic [DATA_WIDTH-1:0] start_val,   // Start value of the sequence
    input logic [DATA_WIDTH-1:0] step_size,   // Step size of the sequence
    output logic [WIDTH_OUT_VAL-1:0] out_val, // Current value of the sequence
    output logic done                        // High when sequence generation is complete
);

  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------
  localparam WIDTH_OUT_VAL = DATA_WIDTH; // Assuming WIDTH_OUT_VAL is the same as DATA_WIDTH

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------
    // (Interface definitions remain the same as above)


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
                current_val <= current_val + step_size; // Compute current_val

                if (counter == SEQUENCE_LENGTH - 1) begin
                    done <= 1'b1; // Assert done signal when sequence is complete
                end else begin
                    counter <= counter + 1; // Increment counter
                end
            end else begin
                counter <= counter; // Hold counter and current_val constant during pause
            end
        end
    end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
    assign out_val = current_val;

endmodule
