module continuous_adder #(
    parameter int DATA_WIDTH = 32,
    parameter int THRESHOLD_VALUE = 100,
    parameter bit SIGNED_INPUTS = 1
)(
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire data_valid,
    output wire [DATA_WIDTH-1:0] sum_out,
    output wire sum_ready
);

    logic [DATA_WIDTH-1:0] sum_accum;

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator, reset sum_out and sum_ready
            sum_accum <= 0;
            sum_ready <= 0;
        end
        else begin
            if (data_valid) begin
                // Add input data to the accumulator
                if (SIGNED_INPUTS) begin
                    sum_accum <= sum_accum + data_in;
                end
                else begin
                    sum_accum <= {sum_accum[DATA_WIDTH-2], sum_accum[DATA_WIDTH-1]} + data_in[DATA_WIDTH-2:0];
                end

                // Check if the accumulated sum is >= THRESHOLD_VALUE
                if ((SUMMED_VALUE < 0 && THRESHOLD_VALUE > 0) || (SUMMED_VALUE >= 0 && SUMMED_VALUE < THRESHOLD_VALUE)) begin
                    // Output the current sum and reset the accumulator
                    sum_out <= SUMMED_VALUE;
                    sum_ready <= 1;
                    sum_accum <= 0;
                }
                else begin
                    // Continue accumulating, but no output until the sum reaches THRESHOLD_VALUE
                    sum_ready <= 0;
                end
            end
        end
    end

endmodule