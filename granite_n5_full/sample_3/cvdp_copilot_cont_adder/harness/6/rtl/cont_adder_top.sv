module continuous_adder #(
    parameter DATA_WIDTH = 32,
    parameter THRESHOLD_VALUE = 100,
    parameter SIGNED_INPUTS = 1
) (
    input logic         clk,             // Clock signal
    input logic         reset,           // Reset signal, Active high and Synchronous
    input logic [DATA_WIDTH-1:0] data_in,     // Input data stream (DATA_WIDTH-bits)
    input logic         data_valid,      // Input data valid signal
    output logic [DATA_WIDTH-1:0]  sum_out,     // Output the accumulated sum
    output logic        sum_ready        // Signal to indicate sum is output and accumulator is reset
);

    logic [DATA_WIDTH-1:0] sum_accum;        // Internal accumulator to store the running sum
    logic [DATA_WIDTH-1:0] threshold;        // Threshold value used for triggering output
    logic signed_accum;                    // Internal flag to indicate signed accumulation

    // Parameterized threshold value
    assign threshold = (SIGNED_INPUTS == 1)? ((1 << (DATA_WIDTH-1)) - THRESHOLD_VALUE) : -(THRESHOLD_VALUE);

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator, reset sum_out and sum_ready
            sum_accum         <= 0;
            sum_ready         <= 1'b0;
            signed_accum       <= 1'b0;
        end
        else begin
            if (data_valid) begin
                // Add input data to the accumulator
                sum_accum     <= sum_accum + data_in;

                // Check if the accumulated sum is >= threshold
                if (signed_accum == 1'b1 || sum_accum >= threshold) begin
                    // Output the current sum and reset the accumulator
                    sum_out   <= sum_accum + data_in; // Output the accumulated sum
                    sum_ready <= 1'b1;                // Indicate that the sum is ready
                    sum_accum <= 0;                // Reset the accumulator
                end
                else begin
                    // Continue accumulating, but no output until the sum reaches threshold
                    sum_ready <= 1'b0;                // No output yet
                }
            end
        end
    end

endmodule