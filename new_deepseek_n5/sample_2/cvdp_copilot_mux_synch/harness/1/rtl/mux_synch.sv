module nff (
    input reg [7:0] d_in,    //input data that needs to be synchronized to the dst_clk domain.
    input dst_clk,      //destination domain clock.
    input rst,          //asynchronous active-low reset
    output reg syncd  //synchronized output, which is stable and free from metastability effects caused by clock domain crossing.
  );
  
  wire q1, q2;
  
  positive_edge sensitive to dst_clk;
  
  if (rst) begin
    q1 = 0;
    q2 = 0;
  else begin
    q1 = d_in;
    q2 = q1;
  end
endmodule