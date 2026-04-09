module mux_synch (

	input [7:0] data_in,   			//asynchronous data input
	input req,                  		//indicating that data is available at the data_in input
	input dst_clk,                 		//destination clock
	input src_clk,                 		//source clock
    	input nrst,                    		//asynchronous reset 
	output reg [7:0] data_out ); 		//synchronized version of data_in to the destination clock domain


reg [7:0] syncd_q;

always @(posedge src_clk or negedge nrst) begin
  if (!nrst) begin
  	syncd_q <= 8'b0000000;
  end else if (req) begin
  	syncd_q <= data_in;
  end
end

assign data_out = syncd_q;

endmodule

module nff  (
	
	input d_in,   									//input data that needs to be synchronized to the dst_clk domain.
	input dst_clk,     								//destination domain clock.
	input rst,         								//asynchronous active-low reset
	output reg  syncd 								//synced output, which is a 2-clock-cycle delayed version of d_in.
	                   );

reg [7:0] syncd_q;

always @(posedge dst_clk or negedge rst) begin
  if (!rst) begin
  	syncd_q <= 8'b0000000;
  end else begin
  	syncd_q <= {syncd_q[6:0], d_in};
  end
end

assign syncd = syncd_q[7];

endmodule