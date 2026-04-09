module serial_in_parallel_out_8bit(
  input wire clock, 
  input wire serial_in,
  output reg [7:0] parallel_out
);
  
  always @(posedge clock) begin
    if (serial_in == 1) begin
      parallel_out[0] <= serial_in;
      parallel_out[7:1] <= parallel_out[6:0];
    end
  end
  
endmodule