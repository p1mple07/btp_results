module mux_synch (

	input [7:0] data_in,   			//asynchronous data input
	input req,                  		//indicating that data is available at the data_in input
	input dst_clk,                 		//destination clock
	input src_clk,                 		//source clock
    	input nrst,                    		//asynchronous reset 
	output reg [7:0] data_out ); 		//synchronized version of data_in to the destination clock domain


reg [7:0] dff1;
reg [7:0] dff2;
reg ena;

assign ena = req & ~nrst;
assign data_out = (ena)? dff2 : dff1;

always @(posedge src_clk) begin

	dff1 <= dff1[6:0] | data_in;
	dff2 <= dff2[6:0] | dff1[7];

end

endmodule

module nff  (
	
	input d_in,   									//input data that needs to be synchronized to the dst_clk domain.
	input dst_clk,     								//destination domain clock.
	input rst,         								//asynchronous active-low reset
	output reg  syncd 								//synced output, which is a 2-clock-cycle delayed version of d_in.
	                   );

reg [7:0] dff1;
reg [7:0] dff2;

always @(posedge dst_clk) begin

	dff1 <= dff1[6:0] | d_in;
	dff2 <= dff2[6:0] | dff1[7];

end

endmodule