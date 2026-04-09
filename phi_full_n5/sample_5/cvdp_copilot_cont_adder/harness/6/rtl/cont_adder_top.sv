
module continuous_adder #(
    parameter DATA_WIDTH = 32,
    parameter THRESHOLD_VALUE = 100,
    parameter SIGNED_INPUTS = 1
) (
    input logic         clk,         // Clock signal
    input logic         reset,       // Reset signal, Active high and Synchronous
    input logic [DATA_WIDTH-1:0] data_in,     // Input data stream (8-bit or width specified by DATA_WIDTH)
    input logic         data_valid,  // Input data valid signal
    output logic [DATA_WIDTH-1:0] sum_out,     // Output the accumulated sum
    output logic        sum_ready    // Signal to indicate sum is output and accumulator is reset
);

    logic [DATA_WIDTH-1:0] sum_accum;          // Internal accumulator to store the running sum

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator, reset sum_out and sum_ready
            sum_accum <= (SIGNED_INPUTS ? 0 : (2**(DATA_WIDTH-1)-1));
            sum_ready <= 1'b0;
        end
        else begin
            if (data_valid) begin
                // Add input data to the accumulator
                if (SIGNED_INPUTS) begin
                    sum_accum <= sum_accum + data_in;
                end else begin
                    sum_accum <= sum_accum + (data_in >> 1); // Convert to unsigned before adding
                end

                // Check if the accumulated sum is greater than or equal to THRESHOLD_VALUE
                // or less than or equal to the negative of THRESHOLD_VALUE when SIGNED_INPUTS is enabled
                if ((SIGNED_INPUTS && (sum_accum >= THRESHOLD_VALUE || sum_accum <= -THRESHOLD_VALUE)) ||
                    (!SIGNED_INPUTS && sum_accum >= THRESHOLD_VALUE)) begin
                    // Output the current sum and reset the accumulator
                    sum_out <= sum_accum;
                    sum_ready <= 1'b1;
                    sum_accum <= (SIGNED_INPUTS ? 0 : (2**(DATA_WIDTH-1)-1));
                end
                else begin
                    // Continue accumulating, but no output until the sum reaches THRESHOLD_VALUE
                    sum_ready <= 1'b0;
                end
            end
        end
    end
endmodule
