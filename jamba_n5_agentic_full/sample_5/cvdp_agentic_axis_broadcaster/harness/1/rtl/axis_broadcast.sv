
initial begin
$monitor("Time=%0t, s_axis_tdata=%h, m_axis_tdata_1=%h, m_axis_tdata_2=%h, m_axis_tdata_3=%h,", $time, s_axis_tdata, m_axis_tdata_1, m_axis_tdata_2, m_axis_tdata_3);

        clk = 0;
        rst_n = 0;
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        m_axis_tready_1 = 0;
        m_axis_tready_2 = 0;
        m_axis_tready_3 = 0;
        
        // Reset sequence
        #20 rst_n = 1;

        m_axis_tready_1 = 1;
        m_axis_tready_2 = 1;
        m_axis_tready_3 = 1;
        wait(s_axis_tready);

        
        // Apply input data
        @(negedge clk);
        s_axis_tdata = 8'hA5;
        s_axis_tvalid = 1;
        m_axis_tready_1 = 1;
        m_axis_tready_2 = 1;
        m_axis_tready_3 = 1;
        
        @(negedge clk);
        m_axis_tready_1 = 0; 
        s_axis_tdata = 8'h5A;

        
        @(negedge clk);
        m_axis_tready_1 = 1; 
        s_axis_tdata = 8'h5b;
        
        @(negedge clk);
        s_axis_tvalid = 0;
        
        @(negedge clk);
        
        // Change ready signals
        m_axis_tready_1 = 0;
        m_axis_tready_2 = 1;
        m_axis_tready_3 = 1;
        
        #10 s_axis_tvalid = 1;
        s_axis_tdata = 8'hF0;
        
        #10;
        
        $finish;
    end
