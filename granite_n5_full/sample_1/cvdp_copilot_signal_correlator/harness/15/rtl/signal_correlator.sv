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
            sum = sum + (input_signal[i] & reference_signal[i]); 
        end
    end
end

// Clamping the summation to the valid range of 4 bits
assign correlation_output = sum > 15? 15 : (sum < 0? 0 : sum);

endmodule