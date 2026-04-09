module enable_synch_1 (.d_in(ack),.dst_clk(src_clk),.rst(nrst),.syncd(syncd_ack));

reg dmeta_ack;

always@(posedge dst_clk or negedge rst)
begin
    if(!rst)
        dmeta_ack <= 1'b0;
    else
        dmeta_ack <= d_in;
    syncd_ack <= dmeta_ack;
end

assign ack_out = dmeta_ack;