module continuous_adder (
    input logic         clk,         // Clock signal
    input logic         reset,       // Reset signal, Active high and Synchronous
    input logic [{DATA_WIDTH}-1:0]   data_in,     // Input data stream (DATA_WIDTH bit)
    input logic         data_valid,  // Input data valid signal
    output logic [{DATA_WIDTH}-1:0]  sum_out,     // Output the accumulated sum
    output logic        sum_ready    // Signal to indicate sum is output and accumulator is reset
);

    parameter logic parameter DATA_WIDTH = 32;
    parameter logic parameter THRESHOLD_VALUE = 100;
    parameter logic parameter SIGNED_INPUTS = 1;

    logic [{DATA_WIDTH}-1:0] sum_accum;          // Internal accumulator to store the running sum

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
                sum_accum     <= sum_accum + data_in;

                // Check if the accumulated sum is >= THRESHOLD_VALUE or <= -THRESHOLD_VALUE
                if (SIGNED_INPUTS) begin
                    if (sum_accum >= THRESHOLD_VALUE || sum_accum <= -THRESHOLD_VALUE) begin
                        // Output the current sum and reset the accumulator
                        sum_out   <= sum_accum;
                        sum_ready <= 1'b1;
                        sum_accum <= ({DATA_WIDTH}-1:0) 0;
                    end
                    else begin
                        // Continue accumulating, but no output until the sum reaches 100
                        sum_ready <= 1'b0;
                    end
                end
                else begin
                    if (sum_accum + data_in >= THRESHOLD_VALUE) begin
                        // Output the current sum and reset the accumulator
                        sum_out   <= sum_accum + data_in;
                        sum_ready <= 1'b1;
                        sum_accum <= 8'd0;
                    end
                    else begin
                        // Continue accumulating, but no output yet
                        sum_ready <= 1'b0;
                    end
                end
            end
        end
    end

    // Constraint check for signed inputs
    if (!SIGNED_INPUTS && THRESHOLD_VALUE >= (1 << DATA_WIDTH)) begin
        $error "THRESHOLD_VALUE must be less than 2^DATA_WIDTH when SIGNED_INPUTS is 0";
    end
    if (SIGNED_INPUTS && THRESHOLD_VALUE >= (1 << (DATA_WIDTH-1))) begin
        $error "THRESHOLD_VALUE must be less than 2^(DATA_WIDTH-1) when SIGNED_INPUTS is 1";
    end
endmodule