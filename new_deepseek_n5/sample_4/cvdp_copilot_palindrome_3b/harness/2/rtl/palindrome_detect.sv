module palindrome_detect #( 
parameter N=3
) (
input clk,
input reset,
input bit_stream,
output palindrome_detected
);
  
  wire [N-1:0] bit_FIFO;
  integer i;
  
  initial begin
    i = 0;
    bit_FIFO = { {3'b0}, {3'b0}, {3'b0} };
  end
  
  forever begin
    if (reset) begin
      bit_FIFO = { {3'b0}, {3'b0}, {3'b0} };
      palindrome_detected = 0;
      sleep(10);
    end else begin
      bit_FIFO = { bit_FIFO[2], bit_stream };
      if (bit_FIFO[0] == bit_FIFO[2]) begin
        palindrome_detected = 1;
      else begin
        palindrome_detected = 0;
      end
    end
    sleep(10);
  end
endmodule