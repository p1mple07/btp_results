module palindrome_detect #( 
parameter N=3
) (
input clk,
input reset,
input bit_stream,
output palindrome_detected
);
reg [N-1:0] data;
reg [N-1:0] reversed_data;
reg [2*N-1:0] concat_data;
wire [2*N-1:0] compare_result;

always @(posedge clk or posedge reset) begin
  if(reset) begin
    data <= 'b0;
    reversed_data <= 'b0;
    palindrome_detected <= 1'b0;
  end else begin
    data[0] <= bit_stream;
    reversed_data <= data >> 1;
    compare_result <= {reversed_data, data};
    palindrome_detected <= ~compare_result[N+N-1:N];
  end
end

endmodule