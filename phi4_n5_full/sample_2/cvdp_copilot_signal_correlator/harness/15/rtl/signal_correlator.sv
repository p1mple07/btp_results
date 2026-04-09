module signal_correlator(
    input clk,
    input reset,
    input [7:0] input_signal,
    input [7:0] reference_signal,
    output reg [3:0] correlation_output
);

    integer i;
    reg [3:0] sum;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            correlation_output <= 0;
            sum <= 0;
        end else begin
            sum <= 0;
            // Compute weighted sum: each matching bit adds +2
            for (i = 0; i < 8; i = i + 1) begin
                sum <= sum + 2 * (input_signal[i] & reference_signal[i]);
            end
            // Clamp the output to 15 if sum exceeds 15
            if (sum > 15)
                correlation_output <= 15;
            else
                correlation_output <= sum;
        end
    end

endmodule