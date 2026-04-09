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
    else begin
        sum = 0;
        for (i = 0; i < 8; i = i + 1) begin
            sum = sum + 2 * (input_signal[i] & reference_signal[i]); 
        end
        correlation_output = sum > 15 ? 15 : sum;
    end
end

endmodule