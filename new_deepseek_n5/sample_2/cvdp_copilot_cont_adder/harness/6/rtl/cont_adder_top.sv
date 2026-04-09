module continuous_adder (
    input logic         clk,         // Clock signal
    input logic         reset,       // Reset signal, Active high and Synchronous
    input logic [#{DATA_WIDTH}-1:0]   data_in,     // Input data stream (DATA_WIDTH bit)
    input logic         data_valid,  // Input data valid signal
    output logic [#{DATA_WIDTH}-1:0]  sum_out,     // Output the accumulated sum
    output logic        sum_ready    // Signal to indicate sum is output and accumulator is reset
);

    parameter logic         DATA_WIDTH     = 32;  // Width of data stream and accumulator
    parameter logic         THRESHOLD_VALUE  = 100; // Threshold value for sum accumulation
    parameter logic         SIGNED_INPUTS   = 1;  // Enable signed arithmetic (1) or unsigned (0)

    logic [#{DATA_WIDTH}-1:0] sum_accum;          // Internal accumulator to store the running sum

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator, reset sum_out and sum_ready
            sum_accum         <= 8'd0;
            sum_ready         <= 1'b0;
        end
        else begin
            if (data_valid) begin
                // Add input data to the accumulator
                logic signed [#{DATA_WIDTH}-1:0] data_signed = data_in;  // Cast to signed if needed
                sum_accum     <= sum_accum + data_signed;

                // Check if the accumulated sum meets threshold condition
                logic signed [#{DATA_WIDTH}-1:0] positive_threshold = THRESHOLD_VALUE;
                logic signed [#{DATA_WIDTH}-1:0] negative_threshold = -(THRESHOLD_VALUE);

                if ((sum_accum >= positive_threshold) || (sum_accum <= negative_threshold)) begin
                    // Output the current sum and reset the accumulator
                    sum_out   <= sum_accum; // Output the accumulated sum
                    sum_ready <= 1'b1;                // Indicate that the sum is ready
                    sum_accum <= 8'd0;                // Reset the accumulator
                end
                else begin
                    // Continue accumulating, but no output until the sum reaches 100
                    sum_ready <= 1'b0;                // No output yet
                end
            end
        end
    end

endmodule