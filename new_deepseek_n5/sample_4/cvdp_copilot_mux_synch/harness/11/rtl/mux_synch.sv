// acknowledgment signal generation
always_ff@(posedge dst_clk or negedge nrst)
begin
    if(!nrst)
        ack <= 1'b0; 
    else if (acked_req==1'b1)
        ack <= 1'b1;
    else
        ack <= 1'b0;
end

//changing the clock domain of the ack signal
nff  enable_synch_1 (.d_in(ack),.dst_clk(src_clk),.rst(nrst),.syncd(syncd_ack)) ;

//edge detector circuit
assign ack_out = syncd_ack;

// acknowledgment signal generation with clock domain synchronization
always_ff@(posedge dst_clk or negedge nrst)
begin
    if(!nrst)
        ack_sync <= 1'b0; 
    else if (acked_req==1'b1)
        ack_sync <= 1'b1;
    else
        ack_sync <= 1'b0;
end

// changing the clock domain of the ack_sync signal
nff  enable_synch_2 (.d_in(ack_sync),.dst_clk(src_clk),.rst(nrst),.syncd(ack_out)) ;