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
        correlation_output <= 4'd0;
        sum <= 4'd0;
    end else begin
        sum = 4'd0;
        for (i = 0; i < 8; i = i + 1) begin
            // Add +2 for each matching bit.
            sum = sum + 2 * (input_signal[i] & reference_signal[i]);
        end
        // Clamp the output to 15 if the sum exceeds 15.
        correlation_output <= (sum > 4'd15) ? 4'd15 : sum;
    end
end

endmodule