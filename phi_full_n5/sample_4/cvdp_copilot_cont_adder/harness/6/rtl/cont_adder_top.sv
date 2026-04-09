
module continuous_adder (
    input logic         clk,         // Clock signal
    input logic         reset,       // Reset signal, Active high and Synchronous
    input logic [DATA_WIDTH-1:0] data_in,     // Input data stream (8-bit)
    input logic           data_valid,  // Input data valid signal
    output logic [DATA_WIDTH-1:0] sum_out,     // Output the accumulated sum
    output logic         sum_ready    // Signal to indicate sum is output and accumulator is reset
    parameter DATA_WIDTH = 8,              // Default value: 8
    parameter THRESHOLD_VALUE = 100,        // Default value: 100
    parameter SIGNED_INPUTS = 1           // Default value: 1 (signed arithmetic enabled)
);

    logic [DATA_WIDTH-1:0] sum_accum;          // Internal accumulator to store the running sum

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator, reset sum_out and sum_ready
            sum_accum <= (SIGNED_INPUTS' == 1) ? 0 : (DATA_WIDTH' == 8) ? 8'd0 : (DATA_WIDTH' == 16) ? 16'd0 : (DATA_WIDTH' == 32) ? 32'd0 : 0;
            sum_ready <= 1'b0;                // Reset the accumulator and sum_ready
        end
        else begin
            if (data_valid) begin
                // Add input data to the accumulator
                if (SIGNED_INPUTS' == 1) begin
                    sum_accum     <= sum_accum + data_in;
                end
                else begin
                    sum_accum     <= sum_accum + logic'(data_in);
                end

                // Check if the accumulated sum is >= or <= THRESHOLD_VALUE based on SIGNED_INPUTS
                if (SIGNED_INPUTS' == 1) begin
                    if (sum_accum >= THRESHOLD_VALUE || sum_accum <= -THRESHOLD_VALUE) begin
                        // Output the current sum and reset the accumulator
                        sum_out   <= sum_accum; // Output the accumulated sum
                        sum_ready <= 1'b1;    // Indicate that the sum is ready
                        sum_accum <= (SIGNED_INPUTS' == 1) ? 0 : (DATA_WIDTH' == 8) ? 8'd0 : (DATA_WIDTH' == 16) ? 16'd0 : (DATA_WIDTH' == 32) ? 32'd0 : 0;
                    end
                    else begin
                        // Continue accumulating, but no output until the sum reaches THRESHOLD_VALUE
                        sum_ready <= 1'b0;    // No output yet
                    end
                end
                else begin
                    if (sum_accum >= THRESHOLD_VALUE && sum_accum < (2**(DATA_WIDTH-1) - THRESHOLD_VALUE)) begin
                        // Output the current sum and reset the accumulator
                        sum_out   <= sum_accum; // Output the accumulated sum
                        sum_ready <= 1'b1;    // Indicate that the sum is ready
                        sum_accum <= (SIGNED_INPUTS' == 1) ? 0 : (DATA_WIDTH' == 8) ? 8'd0 : (DATA_WIDTH' == 16) ? 16'd0 : (DATA_WIDTH' == 32) ? 32'd0 : 0;
                    end
                    else begin
                        // Continue accumulating, but no output until the sum reaches THRESHOLD_VALUE
                        sum_ready <= 1'b0;    // No output yet
                    end
                end
            end
        end
    end
endmodule
