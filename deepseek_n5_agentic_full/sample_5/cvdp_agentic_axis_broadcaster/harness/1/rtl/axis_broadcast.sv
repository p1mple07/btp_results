// Updated broadcast logic: send data when input changes, not just when all outputs are ready
always @(posedgeclk or posedge rst_n) begin
    if (~rst_n) begin
        // Initialize buffers
        s_axis_tdata_buffer <= 0;
        m_axis_tdata_1_reg <= 0;
        m_axis_tvalid_1_reg <= 0;
        m_axis_tdata_2_reg <= 0;
        m_axis_tvalid_2_reg <= 0;
        m_axis_tdata_3_reg <= 0;
        m_axis_tvalid_3_reg <= 0;
    else begin
        if (s_axis_tdata) begin
            s_axis_tdata_buffer <= s_axis_tdata;
        end
        
        // Broadcast input data to outputs
        if (s_axis_tdata_buffer != 0) begin
            m_axis_tdata_1_reg <= s_axis_tdata_buffer;
            m_axis_tdata_2_reg <= s_axis_tdata_buffer;
            m_axis_tdata_3_reg <= s_axis_tdata_buffer;
        end
        
        if (~s_axis_tvalid || (s_axis_tdata_buffer == 0)) begin
            m_axis_tvalid_1_reg <= 0;
            m_axis_tvalid_2_reg <= 0;
            m_axis_tvalid_3_reg <= 0;
        else begin
            m_axis_tvalid_1_reg <= 1;
            m_axis_tvalid_2_reg <= 1;
            m_axis_tvalid_3_reg <= 1;
        end
    end
end

// Update receiver readiness based on data reception
always @(posedgeclk or posedge rst_n) begin
    if (~rst_n) begin
        s_axis_tready <= 0;
    else begin
        if (m_axis_tvalid_1_reg || m_axis_tvalid_2_reg || m_axis_tvalid_3_reg) begin
            s_axis_tready <= 1;
        else begin
            s_axis_tready <= 0;
        end
    end
end