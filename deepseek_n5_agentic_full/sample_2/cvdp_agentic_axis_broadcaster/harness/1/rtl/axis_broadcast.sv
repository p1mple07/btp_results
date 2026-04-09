// Broadcast logic: enable each output individually based on their readiness
assign m_axis_tdata_1 = (m_axis_tready_1 && s_axis_tvalid) ? s_axis_tdata : 0;
assign m_axis_tvalid_1 = s_axis_tvalid;
assign m_axis_tdata_2 = (m_axis_tready_2 && s_axis_tvalid) ? s_axis_tdata : 0;
assign m_axis_tvalid_2 = s_axis_tvalid;
assign m_axis_tdata_3 = (m_axis_tready_3 && s_axis_tvalid) ? s_axis_tdata : 0;
assign m_axis_tvalid_3 = s_axis_tvalid;

// Determine if any receiver is ready to accept new data
wire reg m_axis_any_ready = m_axis_tready_1 || m_axis_tready_2 || m_axis_tready_3;

// Update s_axis_tready based on receiver readiness
always @(posedge clock or negedge rst_n)
begin
    if (~rst_n) 
    begin
        s_axis_tready <= 0;
    else 
        s_axis_tready <= m_axis_any_ready ;
end