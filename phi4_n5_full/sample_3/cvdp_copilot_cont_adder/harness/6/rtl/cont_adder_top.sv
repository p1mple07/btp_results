module continuous_adder #(
    parameter DATA_WIDTH      = 32,
    parameter THRESHOLD_VALUE = 100,
    parameter SIGNED_INPUTS   = 1  // 1 = signed arithmetic, 0 = unsigned arithmetic
)(
    input  logic                  clk,         // Clock signal
    input  logic                  reset,       // Reset signal, Active high and Synchronous
    input  logic [DATA_WIDTH-1:0] data_in,     // Input data stream
    input  logic                  data_valid,  // Input data valid signal
    output logic [DATA_WIDTH-1:0] sum_out,     // Output the accumulated sum
    output logic                  sum_ready    // Signal to indicate sum is output and accumulator is reset
);

    // Internal accumulator register
    logic [DATA_WIDTH-1:0] sum_accum;

    // Generate block to select signed or unsigned arithmetic based on SIGNED_INPUTS parameter
    generate
        if (SIGNED_INPUTS) begin : signed_arith
            always_ff @(posedge clk) begin
                if (reset) begin
                    sum_accum <= '0;
                    sum_ready <= 1'b0;
                end
                else begin
                    if (data_valid) begin
                        // Compute new accumulated sum using signed arithmetic
                        logic signed [DATA_WIDTH-1:0] new_sum;
                        new_sum = $signed(sum_accum) + $signed(data_in);
                        
                        // Default: indicate that sum is not ready
                        sum_ready <= 1'b0;
                        
                        // Check threshold condition:
                        // If new_sum is greater than or equal to THRESHOLD_VALUE
                        // OR less than or equal to -THRESHOLD_VALUE, then output the sum and reset accumulator.
                        if ((new_sum >= THRESHOLD_VALUE) || (new_sum <= -THRESHOLD_VALUE)) begin
                            sum_out   <= new_sum;
                            sum_ready <= 1'b1;
                            sum_accum <= '0;
                        end
                        else begin
                            // Continue accumulating the sum
                            sum_accum <= new_sum;
                        end
                    end
                end
            end
        end
        else begin : unsigned_arith
            always_ff @(posedge clk) begin
                if (reset) begin
                    sum_accum <= '0;
                    sum_ready <= 1'b0;
                end
                else begin
                    if (data_valid) begin
                        // Compute new accumulated sum using unsigned arithmetic
                        logic [DATA_WIDTH-1:0] new_sum;
                        new_sum = sum_accum + data_in;
                        
                        // Default: indicate that sum is not ready
                        sum_ready <= 1'b0;
                        
                        // Check threshold condition for unsigned data:
                        if (new_sum >= THRESHOLD_VALUE) begin
                            sum_out   <= new_sum;
                            sum_ready <= 1'b1;
                            sum_accum <= '0;
                        end
                        else begin
                            // Continue accumulating the sum
                            sum_accum <= new_sum;
                        end
                    end
                end
            end
        end
    endgenerate

endmodule