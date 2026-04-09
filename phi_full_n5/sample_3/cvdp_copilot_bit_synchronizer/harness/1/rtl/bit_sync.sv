// Synchronization for aclk domain
always_ff @(posedge aclk or negedge rst_n) begin
    if (!rst_n)
        a_sync_chain <= {STAGES{1'b0}};
    else
        a_sync_chain <= {a_sync_chain[STAGES-2:0], bq2_data};
end

assign aq2_data = a_sync_chain[STAGES-1];
