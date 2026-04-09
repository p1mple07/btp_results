module mux_synch (

	input [7:0] data_in,   			//asynchronous data input
	input req,                  		//indicating that data is available at the data_in input
	input dst_clk,                 		//destination clock
	input src_clk,                 		//source clock
    	input nrst,                    		//asynchronous reset 
	output reg [7:0] data_out ); 		//synchronized version of data_in to the destination clock domain


reg [7:0] temp_data;
reg [1:0] delay = 0;
always @(posedge src_clk) begin
  if(delay == 1 && req) begin
    temp_data <= data_in;
  end
  else if(delay == 2) begin
    data_out <= temp_data;
  end
  delay <= delay + 1;
end

endmodule

module nff  (
	
	input d_in,   									//input data that needs to be synchronized to the dst_clk domain.
	input dst_clk,     								//destination domain clock.
	input rst,         								//asynchronous active-low reset
	output reg  syncd 								//synced output, which is a 2-clock-cycle delayed version of d_in.
	                   );

always @(posedge dst_clk) begin
  if(rst) begin
    syncd <= 1'b0;
  end
  else begin
    syncd <= d_in;
  end
end

endmodule