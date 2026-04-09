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
        correlation_output <= 4'b0000; // Initialize to 0
        sum = 4'b0000; // Initialize sum to 0
    end else begin
        sum = 4'b0000; // Reset sum to 0 for each positive edge of clk
        for (i = 0; i < 8; i = i + 1) begin
            if (input_signal[i] == reference_signal[i]) begin
                sum = sum + 2'b10; // Add weight of +2 for matching bits
            end
        end
        if (sum > 4'b1111) begin
            sum = 4'b1111; // Clamp output if it exceeds 4-bit range
        end
        correlation_output <= sum;
    end
end

endmodule
