// ... existing code ...

always @(posedge clk or negedge rst_n) 
begin
    if (~rst_n) 
    begin
        // ... initialization ...
    end 
    else if (s_axis_tready_t1)
    begin
        // Assign data AFTER verifying readiness
        m_axis_tdata_1_reg  <= s_axis_tdata;
        m_axis_tvalid_1_reg <= s_axis_tvalid;
        m_axis_tdata_2_reg  <= s_axis_tdata;
        m_axis_tvalid_2_reg <= s_axis_tvalid;
        m_axis_tdata_3_reg  <= s_axis_tdata;
        m_axis_tvalid_3_reg <= s_axis_tvalid;
    end
end

always @(posedge clk or negedge rst_n) 
begin
    if (~rst_n) 
    s_axis_tready <= 0;
    else 
        s_axis_tready <= s_axis_tready_t1 ;
    end
end

// ... rest of the code ...

#20 rst_n = 1;
        m_axis_tready_1 = 1;
        m_axis_tready_2 = 1;
        m_axis_tready_3 = 1;
        // Assert validity BEFORE broadcasting
        @expect s_axis_tvalid 0
        $finish;
        
        // Apply input data
        @(negedge clk);
        s_axis_tdata = 8'hA5;
        s_axis_tvalid = 1;
        m_axis_tready_1 = 1;
        m_axis_tready_2 = 1;
        m_axis_tready_3 = 1;
        
        // Wait for data to be accepted
        @expect s_axis_tvalid 0
        $finish;