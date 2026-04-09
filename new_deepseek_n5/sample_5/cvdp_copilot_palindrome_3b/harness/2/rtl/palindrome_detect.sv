module palindrome_detect #( 
parameter N=3
) (
input clk,
input reset,
input bit_stream,
output palindrome_detected
);
  
  wire [3] fifo; // FIFO size N+1 to handle shifting
  wire palindrome;
  
  if (reset) 
    fifo = {3{X}};
    palindrome = 0;
  else 
    fifo =fifo << bit_stream;
    palindrome = (fifo[0] == fifo[N-1]);
  endif
  
  palindrome_detected = palindrome;
  
endmodule