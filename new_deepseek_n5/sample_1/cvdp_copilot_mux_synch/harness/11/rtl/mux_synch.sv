// acknowledgment signal generation
always_ff@(posedge dst_clk or posedge src_clk or negedge nrst)
begin
	if(!nrst)
		ack <= 1'b0; 

	else if (anded_req==1'b1)
		ack <= 1'b1;
	
	else
		ack <= 1'b0;
end