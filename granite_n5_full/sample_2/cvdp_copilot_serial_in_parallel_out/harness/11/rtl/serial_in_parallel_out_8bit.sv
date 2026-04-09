module serial_in_parallel_out_8bit (input clock,serial_in,output reg [7:0] parallel_out);
  
always @(posedge clock)  
  begin
    parallel_out[7:1] <=parallel_out[6:0];     
    parallel_out[0] <= serial_in;  
  end  
  
endmodule