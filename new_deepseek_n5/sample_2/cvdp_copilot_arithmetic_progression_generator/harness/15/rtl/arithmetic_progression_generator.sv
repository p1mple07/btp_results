module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,
    parameter SEQUENCE_LENGTH = 0 // Number of terms in the progression
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

    localparam WIDTH_OUT_VAL = ($sequence_length == 0) ? 0 : ($clog2($sequence_length) + DATA_WIDTH); // Bit width of out_val to prevent overflow

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
    logic [$clog2($sequence_length)-1:0] counter;  // Counter to track sequence length

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
                if (counter == 0) begin
                    current_val <= start_val; // Initialize with start value
                end else begin
                    current_val <= current_val + step_size; // Compute next term
                end

                if (counter < $sequence_length - 1) begin
                    counter <= counter + 1; // Increment counter
                end else begin
                    done <= 1'b1; // Mark completion
                end
            end
        end
    end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
    assign out_val = current_val;

endmodule