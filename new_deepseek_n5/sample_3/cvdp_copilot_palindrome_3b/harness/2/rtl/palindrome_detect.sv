module palindrome_detect #( 
parameter N=3
) (
input clk,
input reset,
input bit_stream,
output palindrome_detected
);
  
reg reg1, reg2, reg3;
reg counter, detection_flag;
  
if (!reset) begin
  reg1 = 0;
  reg2 = 0;
  reg3 = 0;
  counter = 0;
  detection_flag = 0;
end
  
if (counter == N-1) begin
  reg1 = bit_stream;
  reg2 = reg1;
  reg3 = reg2;
  counter = N;
  
  if (reg1 == reg3) begin
    detection_flag = 1;
  end
  
  // Reset on next clock cycle
  #2
  detection_flag = 0;
  counter = 0;
end
  
// Output the detection flag on the next clock cycle
#1
palindrome_detected = detection_flag;
  
endmodule