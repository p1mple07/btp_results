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

localparam WIDTH_OUT_VAL = $clog2(SEQUENCE_LENGTH) + DATA_WIDTH; // Bit width of out_val to prevent overflow

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
signed [WIDTH_OUT_VAL-1:0] current_val;  // Register to hold the current value
signed [$clog2(SEQUENCE_LENGTH)-1:0] counter;  // Counter to track sequence length

// ----------------------------------------
// - Procedural block
// ----------------------------------------
always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        current_val <= 0;
        counter <= 0;
        done <= 1'b0;
    end else begin
        if (!enable) begin
            // Skip processing when enable is false
            always_ff @(posedge clk or negedge resetn) begin
                // Do nothing
            end
        end else begin
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

  assign out_val = current_val;

endmodule
