
always_ff@(posedge dst_clk or negedge nrst)
begin
    if(!nrst)
        ack <= 1'b0; 

    else if (anded_req==1'b1)
        ack <= 1'b1;

    else
        ack <= 1'b0;
end

nff  enable_synch_1 (.d_in(ack),.dst_clk(src_clk),.rst(nrst),.syncd(syncd_ack)) ;

ack_out = syncd_ack;
