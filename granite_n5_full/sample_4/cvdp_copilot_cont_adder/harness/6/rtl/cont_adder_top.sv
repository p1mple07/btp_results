module continuous_adder #(
    parameter int DATA_WIDTH = 32,
    parameter int THRESHOLD_VALUE = 100,
    parameter bit SIGNED_INPUTS = 1
) (
    input wire logic         clk,
    input wire logic         reset,
    input wire logic [DATA_WIDTH-1:0]   data_in,
    input wire logic         data_valid,
    output wire logic [DATA_WIDTH-1:0]  sum_out,
    output wire logic        sum_ready
);

logic [DATA_WIDTH-1:0] sum_accum;

// Sequential logic for sum accumulation
always_ff @(posedge clk) begin
    if (reset) begin
        // On reset, clear the accumulator, reset sum_out and sum_ready
        sum_accum         <= 0;
        sum_ready         <= 0;
    end
    else begin
        if (data_valid) begin
            // Add input data to the accumulator
            sum_accum     <= (SIGNED_INPUTS == 1)? 
                sum_accum + signextend(data_in) : 
                sum_accum + data_in;

            // Check if the accumulated sum is >= 100
            if ((SUMMED_VALUE >= 100 && SIGNED_INPUTS == 1) || 
                (SUMMED_VALUE < THRESHOLD_VALUE && SIGNED_INPUTS == 0)) begin
                // Output the current sum and reset the accumulator
                sum_out   <= SUMMED_VALUE; // Output the accumulated sum
                sum_ready <= 1;            // Indicate that the sum is ready
                sum_accum <= 0;            // Reset the accumulator
            end
            else begin
                // Continue accumulating, but no output until the sum reaches 100
                sum_ready <= 0;            // No output yet
            end
        end
    end
end

endmodule