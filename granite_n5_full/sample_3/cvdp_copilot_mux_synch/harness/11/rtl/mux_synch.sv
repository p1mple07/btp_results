module nff  (
	
	input d_in,   									//input data that needs to be synchronized to the dst_clk domain.
	input dst_clk,     								//destination domain clock.
	input rst,         								//asynchronous active-low reset
	output reg  syncd 								//synced output, which is a 2-clock-cycle delayed version of d_in.
	                   );

reg   dmeta;             								//register to hold output.



always@(posedge dst_clk or negedge rst)  
begin
	if(!rst)              								//active-low asynchronous reset
  begin
    syncd <= 1'b0;      								//resetting the synced register to 0
    dmeta <= 1'b0;      								//resetting dmeta register to 0
  end
  else
  begin
    dmeta <= d_in;      								//passing d_in to dmeta
    syncd <= dmeta;     								//passing dmeta to syncd
  end
end

endmodule