
module arithmetic_progression_generator #(
    parameter DATA_WIDTH = 16,  // Width of the input data
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

    // Remove the WIDTH_OUT_VAL calculation to avoid math domain error
    // localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH) + DATA_WIDTH; // Bit width of out_val to prevent overflow

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------
    input logic clk;                          // Clock signal
    input logic resetn;                       // Active-low reset
    input logic enable;                       // Enable signal for the generator
    input logic [DATA_WIDTH-1:0] start_val;   // Start value of the sequence
    input logic [DATA_WIDTH-1:0] step_size;   // Step size of the sequence
    output logic [DATA_WIDTH-1:0] out_val;    // Current value of the sequence
    output logic done;                        // High when sequence generation is complete


  // ----------------------------------------
  // - Internal signals
  // ----------------------------------------
    // current_val remains unchanged
    // counter remains unchanged

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
                // Do not compute next term if SEQUENCE_LENGTH is 0
                if (counter == 0) begin
                    current_val <= start_val; // Initialize with start value
                end
                else begin
                    // Do not increment counter if SEQUENCE_LENGTH is 0
                end

                if (counter < SEQUENCE_LENGTH - 1) begin
                    counter <= counter + 1; // Increment counter
                end
                // done remains 0 as there is no sequence to complete
            end
        end
    end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
    assign out_val = current_val;

endmodule
