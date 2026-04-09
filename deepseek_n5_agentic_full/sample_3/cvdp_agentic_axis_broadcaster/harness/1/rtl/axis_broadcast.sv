// Broadcast logic: forward input to all outputs
assign s_axis_tready_t1 = m_axis_tready_1 && m_axis_tready_2 && m_axis_tready_3;  // Ready only if all outputs are ready

// Always block to handle data transmission
always @(posedge clk or negedge rst_n) 
begin
    if (~rst_n) 
    begin
        // Initialize all outputs
        m_axis_tdata_1_reg  <= 0;
        m_axis_tvalid_1_reg <= 0;
        m_axis_tdata_2_reg  <= 0;
        m_axis_tvalid_2_reg <= 0;
        m_axis_tdata_3_reg  <= 0;
        m_axis_tvalid_3_reg <= 0;
    else 
    begin
        // If there's new data, broadcast it to all outputs that are ready
        if (~s_axis_tvalid) 
        begin
            m_axis_tdata_1_reg  <= s_axis_tdata;
            m_axis_tvalid_1_reg <= 1;
            m_axis_tdata_2_reg  <= s_axis_tdata;
            m_axis_tvalid_2_reg <= 1;
            m_axis_tdata_3_reg  <= s_axis_tdata;
            m_axis_tvalid_3_reg <= 1;
        end
        
        // Update s_axis_tready based on any successful reception
        s_axis_tready <= m_axis_tvalid_1 || m_axis_tvalid_2 || m_axis_tvalid_3;
    end
end

// Wire connections between internal registers and outputs
wire m_axis_tvalid_1 = m_axis_tvalid_1_reg;
wire m_axis_tvalid_2 = m_axis_tvalid_2_reg;
wire m_axis_tvalid_3 = m_axis_tvalid_3_reg;
wire m_axis_tdata_1 = m_axis_tdata_1_reg;
wire m_axis_tdata_2 = m_axis_tdata_2_reg;
wire m_axis_tdata_3 = m_axis_tdata_3_reg;

// Broadcast logic: forward input to all outputs
assign s_axis_tready_t1 = m_axis_tready_1 && m_axis_tready_2 && m_axis_tready_3 ;  // Ready only if all outputs are ready