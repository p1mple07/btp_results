module
=======
// FIFO buffers for each channel
reg FIFO1, FIFO2, FIFO3;
reg [7:0] FIFO1_data, FIFO2_data, FIFO3_data;
reg [0] FIFO1_full, FIFO2_full, FIFO3_full;

// Output signals
wire m_axis_tdata_1, m_axis_tdata_2, m_axis_tdata_3;
wire m_axis_tvalid_1, m_axis_tvalid_2, m_axis_tvalid_3;

// Channel-specific states
reg [1:0] state0, state1, state2, state3;

// State machine
always state0 +-> state1 on posedge rst_n;
always state1 +-> state2 on posedge rst_n;
always state2 +-> state3 on posedge rst_n;
always state3 +-> state0 on posedge rst_n;

always state0: 
    if (!rst_n) 
        FIFO1_full <= 0;
        FIFO2_full <= 0;
        FIFO3_full <= 0;
        FIFO1_data <= 0;
        FIFO2_data <= 0;
        FIFO3_data <= 0;
        m_axis_tready_1 <= 0;
        m_axis_tready_2 <= 0;
        m_axis_tready_3 <= 0;
        m_axis_tdata_1 <= 0;
        m_axis_tvalid_1 <= 0;
        m_axis_tdata_2 <= 0;
        m_axis_tvalid_2 <= 0;
        m_axis_tdata_3 <= 0;
        m_axis_tvalid_3 <= 0;
    else 
        FIFO1_full <= 0;
        FIFO2_full <= 0;
        FIFO3_full <= 0;
        FIFO1_data <= 0;
        FIFO2_data <= 0;
        FIFO3_data <= 0;
        m_axis_tready_1 <= 0;
        m_axis_tready_2 <= 0;
        m_axis_tready_3 <= 0;
        m_axis_tdata_1 <= 0;
        m_axis_tvalid_1 <= 0;
        m_axis_tdata_2 <= 0;
        m_axis_tvalid_2 <= 0;
        m_axis_tdata_3 <= 0;
        m_axis_tvalid_3 <= 0;
    endif

always state1: 
    if (!rst_n || FIFO1_full) 
        FIFO1_data <= s_axis_tdata;
        FIFO1_full <= 1;
    else 
        FIFO1_data <= 0;
        FIFO1_full <= 0;
    endif

always state2: 
    if (!rst_n || FIFO2_full) 
        FIFO2_data <= s_axis_tdata;
        FIFO2_full <= 1;
    else 
        FIFO2_data <= 0;
        FIFO2_full <= 0;
    endif

always state3: 
    if (!rst_n || FIFO3_full) 
        FIFO3_data <= s_axis_tdata;
        FIFO3_full <= 1;
    else 
        FIFO3_data <= 0;
        FIFO3_full <= 0;
    endif

always state0: 
    if (!rst_n) 
        m_axis_tready_1 <= FIFO1_full ? FIFO1_data : 0;
        m_axis_tready_2 <= FIFO2_full ? FIFO2_data : 0;
        m_axis_tready_3 <= FIFO3_full ? FIFO3_data : 0;
        m_axis_tdata_1 <= FIFO1_data;
        m_axis_tvalid_1 <= FIFO1_full;
        m_axis_tdata_2 <= FIFO2_data;
        m_axis_tvalid_2 <= FIFO2_full;
        m_axis_tdata_3 <= FIFO3_data;
        m_axis_tvalid_3 <= FIFO3_full;
    else 
        m_axis_tready_1 <= 0;
        m_axis_tready_2 <= 0;
        m_axis_tready_3 <= 0;
        m_axis_tdata_1 <= 0;
        m_axis_tvalid_1 <= 0;
        m_axis_tdata_2 <= 0;
        m_axis_tvalid_2 <= 0;
        m_axis_tdata_3 <= 0;
        m_axis_tvalid_3 <= 0;
    endif

always @(posedge clk or negedge rst_n) 
begin
    if (~rst_n) 
        s_axis_tready <= 0;
    else 
        s_axis_tready <= FIFO1_full && FIFO2_full && FIFO3_full;
    endif
end

endmodule