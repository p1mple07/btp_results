module palindrome_detect #( 
parameter N=3
) (
input clk,
input reset,
input bit_stream,
output palindrome_detected
);

reg [N-1:0] reg_window;
reg [2*N-1:0] window;
reg [N-1:0] reverse_window;
reg [N-1:0] xor_result;
reg [N-1:0] max_value;
wire [N-1:0] compare_result;

always @(posedge clk) begin
  if(reset) begin
    reg_window <= '0;
    window <= '0;
    reverse_window <= '0;
    xor_result <= '0;
    max_value <= '0;
  end else begin
    reg_window <= {reg_window[N-1:0], bit_stream};
    window <= {reg_window[2*N-1:N], reg_window[N-1:0]};
    reverse_window <= {reg_window[N-1:0], reg_window[2*N-1:N]};
    xor_result <= reg_window ^ window;
    max_value <= {xor_result[N-1:0], reverse_window[N-1:0]};
    palindrome_detected <= (max_value == window);
  end
end

endmodule