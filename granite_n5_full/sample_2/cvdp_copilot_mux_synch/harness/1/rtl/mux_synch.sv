module mux_synch (

	input [7:0] data_in,   			//asynchronous data input
	input req,                  		//indicating that data is available at the data_in input
	input dst_clk,                 		//destination clock
	input src_clk,                 		//source clock
    	input nrst,                    		//asynchronous reset 
	output reg [7:0] data_out ); 		//synchronized version of data_in to the destination clock domain


reg [7:0] s_ff;
reg [7:0] d_ff;

always @(posedge dst_clk or posedge nrst) begin
	if(!nrst) begin
		s_ff <= 8'h0;
		d_ff <= 8'h0;
	end else if(req) begin
		s_ff <= data_in;
		d_ff <= s_ff;
	end else begin
		s_ff <= d_ff;
		d_ff <= s_ff;
	end
end

assign data_out = d_ff;

endmodule

module nff  (
	
	input d_in,   									//input data that needs to be synchronized to the dst_clk domain.
	input dst_clk,     								//destination domain clock.
	input rst,         								//asynchronous active-low reset
	output reg  syncd 								//synced output, which is a 2-clock-cycle delayed version of d_in.
	                   );

always @(posedge dst_clk or posedge rst) begin
	if(!rst) begin
		syncd <= 1'b0;
	end else begin
		syncd <= d_in;
	end
end

endmodule