module palindrome_detect #( 
parameter N=3
) (
input clk,
input reset,
input bit [N-1:0] bit_stream,
output reg palindrome_detected
);
reg [2:0] window [3:0];
reg [2:0] compare;
reg [2:0] next_window;

always @(posedge clk or posedge reset) begin
  if (reset) begin
    window <= {2{1'b0}};
    compare <= {2{1'b0}};
    next_window <= {2{1'b0}};
    palindrome_detected <= 1'b0;
  end else begin
    next_window[0] <= bit_stream[N-1];
    next_window[1] <= bit_stream[N-2];
    next_window[2] <= bit_stream[N-3];
    compare <= window[2];
    window[0] <= window[1];
    window[1] <= window[2];
    window[2] <= next_window[0];
    if (next_window == compare)
      palindrome_detected <= 1'b1;
    else
      palindrome_detected <= 1'b0;
  end
end

endmodule