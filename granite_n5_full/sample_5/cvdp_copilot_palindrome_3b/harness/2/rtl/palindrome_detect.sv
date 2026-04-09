module palindrome_detect #( 
parameter N=3
) (
input clk,
input reset,
input bit_stream,
output palindrome_detected
);

logic [N-1:0] palindrome;
logic [N-1:0] window;
logic [N-1:0] temp_window;
logic [2*N-1:0] window_reg;
logic [2*N-1:0] temp_window_reg;

assign window = {temp_window[N-2:0], temp_window};
assign temp_window_reg = window_reg[N+N-2:N];
assign window_reg = {window_reg[2*N-3:N], temp_window_reg};
assign temp_window = bit_stream? {bit_stream, 1'b0} : 1'b0;

generate
for (genvar i=0; i<N; i++) begin
assign temp_window[i] = (window == palindrome[i:0]) && window[i]!= temp_window[i];
end
endgenerate

assign palindrome_detected = |(palindrome & window);

always_ff @(posedge clk or posedge reset) begin
if (reset) begin
palindrome <= 0;
window_reg <= 0;
temp_window_reg <= 0;
end else begin
palindrome <= palindrome_detected? palindrome + 1 : palindrome;
window_reg <= window_reg;
temp_window_reg <= temp_window_reg;
end
end

endmodule