module continuous_adder (
    input logic         clk,         // Clock signal
    input logic         reset,       // Reset signal, Active high and Synchronous
    input logic [#{DATA_WIDTH}-1:0]   data_in,     // Input data stream (DATA_WIDTH bit)
    input logic         data_valid,  // Input data valid signal
    output logic [#{DATA_WIDTH}-1:0]  sum_out,     // Output the accumulated sum
    output logic        sum_ready    // Signal to indicate sum is output and accumulator is reset
);

    parameter logic signed_data_width = DATA_WIDTH;
    parameter logic threshold_value = THRESHOLD_VALUE;
    parameter logic signed_arithmetic = SIGNED_INPUTS;

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
                sum_accum     <= sum_accum + data_in;

                // Check if the accumulated sum is beyond threshold
                if (signed_arithmetic) begin
                    if (sum_accum >= threshold_value || sum_accum <= -threshold_value) begin
                        // Output the current sum and reset the accumulator
                        sum_out   <= sum_accum;
                        sum_ready <= 1'b1;
                        sum_accum <= 8'd0;
                    end
                    else begin
                        sum_ready <= 1'b0;
                    end
                else begin
                    if (sum_accum + data_in >= threshold_value) begin
                        sum_out   <= sum_accum + data_in;
                        sum_ready <= 1'b1;
                        sum_accum <= 8'd0;
                    end
                    else begin
                        sum_ready <= 1'b0;
                    end
                end
            end
        end
    end

endmodule