module mux_synch (

	input [7:0] data_in,   			//asynchronous data input
	input req,                  		//indicating that data is available at the data_in input
	input dst_clk,                 		//destination clock
	input src_clk,                 		//source clock
    	input nrst,                    		//asynchronous reset 
	output reg [7:0] data_out ); 		//synchronized version of data_in to the destination clock domain


always @(posedge src_clk or posedge nrst) begin
	if(~nrst) begin
		data_out <= 8'b0000_0000; //reset the output signal to 0
	end else if(req) begin
		data_out <= data_in; //select the data input based on the req signal
	end
end

endmodule

module nff  (
	
	input d_in,   									//input data that needs to be synchronized to the dst_clk domain.
	input dst_clk,     								//destination domain clock.
	input rst,         								//asynchronous active-low reset
	output reg  syncd 								//synced output, which is a 2-clock-cycle delayed version of d_in.
	                   );

reg [7:0] delay;

always @(posedge dst_clk or posedge rst) begin
	if(~rst) begin
		delay <= 8'b0000_0000; //reset the delay register
	end else begin
		delay <= {delay[6:0],d_in}; //shift the input data into the delay register
	end
end

assign syncd = delay[1:0]; //assign the synchronized output to the syncd signal

endmodule