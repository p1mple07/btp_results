
module continuous_adder #(
    parameter DATA_WIDTH = 32,
    parameter THRESHOLD_VALUE = 100,
    parameter SIGNED_INPUTS = 1
) (
    input logic clk,
    input logic reset,
    input logic [DATA_WIDTH-1:0] data_in,
    input logic data_valid,
    output logic [DATA_WIDTH-1:0] sum_out,
    output logic sum_ready
);

    logic [DATA_WIDTH-1:0] sum_accum;

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator, reset sum_out and sum_ready
            sum_accum <= (DATA_WIDTH-1'b0);
            sum_ready <= 1'b0;
        end
        else begin
            if (data_valid) begin
                // Add input data to the accumulator
                if (SIGNED_INPUTS) begin
                    sum_accum <= sum_accum + data_in;
                end else begin
                    sum_accum <= sum_accum + logic'(data_in); // Convert to unsigned for addition
                end

                // Check if the accumulated sum is >= THRESHOLD_VALUE
                if ((SIGNED_INPUTS && (sum_accum >= THRESHOLD_VALUE)) ||
                    (!SIGNED_INPUTS && (sum_accum >= (THRESHOLD_VALUE - (1'b1 << (DATA_WIDTH-1)))) ||
                    (sum_accum <= -(THRESHOLD_VALUE - (1'b1 << (DATA_WIDTH-1)))))) begin
                    // Output the current sum and reset the accumulator
                    sum_out <= sum_accum; // Output the accumulated sum
                    sum_ready <= 1'b1;     // Indicate that the sum is ready
                    sum_accum <= (DATA_WIDTH-1'b0); // Reset the accumulator
                end
                else begin
                    // Continue accumulating, but no output until the sum reaches THRESHOLD_VALUE
                    sum_ready <= 1'b0; // No output yet
                end
            end
        end
    end

endmodule
