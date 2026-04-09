module signal_correlator(
    input clk,
    input reset,
    input [7:0] input_signal,
    input [7:0] reference_signal,
    output reg [3:0] correlation_output
);

    integer i;
    // Use a 5-bit register to hold the weighted sum (max value is 16, but we clamp to 15)
    reg [4:0] weighted_sum;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            correlation_output <= 0;
            weighted_sum       <= 0;
        end else begin
            weighted_sum = 0; // reset the sum for this clock cycle
            for (i = 0; i < 8; i = i + 1) begin
                // For each matching bit, add 2; otherwise add 0.
                weighted_sum = weighted_sum + ((input_signal[i] & reference_signal[i]) ? 2 : 0);
            end
            // Clamp the result to 15 if it exceeds the 4-bit maximum.
            if (weighted_sum > 15)
                correlation_output <= 15;
            else
                correlation_output <= weighted_sum;
        end
    end

endmodule