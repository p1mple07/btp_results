
module signal_correlator(
    input clk,
    input reset,
    input [7:0] input_signal,
    input [7:0] reference_signal,
    output reg [3:0] correlation_output // 4-bit output
);

integer i;
reg [3:0] sum;  

always @(posedge clk or posedge reset) begin
    if (reset) begin
        correlation_output <= 0;
        sum = 0;
    end else begin
        sum = 0;
        for (i = 0; i < 8; i = i + 1) begin
            if (input_signal[i] == reference_signal[i]) begin
                sum = sum + 2; // Increment sum by weight of +2 for matching bits
            end
        end
        // Clamping the output to 4-bit range (0-15)
        if (sum > 15) begin
            correlation_output <= 15;
        end else begin
            correlation_output <= sum;
        end
    end
end

endmodule
