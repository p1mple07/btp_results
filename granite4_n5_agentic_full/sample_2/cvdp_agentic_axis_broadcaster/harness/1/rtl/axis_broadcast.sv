module axis_broadcast(
    // AXI Stream interfaces
    input clk,
    input rst_n,
    input [7:0] s_axis_tdata,
    input s_axis_tvalid,
    output s_axis_tready,
    output [7:0] m_axis_tdata_1,
    output [7:0] m_axis_tdata_2,
    output [7:0] m_axis_tdata_3,
    output m_axis_tvalid_1,
    output m_axis_tvalid_2,
    output m_axis_tvalid_3
);

// Broadcast logic: forward input to all outputs

assign s_axis_tready = m_axis_tvalid_1 && m_axis_tvalid_2 && m_axis_tvalid_3? 0 : 1; // RTL bugs: m_axis_tdata_1 = m_axis_tdata_1, m_axis_tdata_2 = m_axis_tdata_2, m_axis_tdata_3 = m_axis_tdata_3

// RTL bugs: m_axis_tdata_1 = m_axis_tdata_1, m_axis_tdata_2 = m_axis_tdata_2, m_axis_tdata_3 = m_axis_tdata_3
assign m_axis_tdata_1 = s_axis_tdata, m_axis_tdata_2 = s_axis_tdata, m_axis_tdata_3 = s_axis_tdata

// RTL bugs: m_axis_tdata_1 = s_axis_tdata, m_axis_tdata_2 = s_axis_tdata, m_axis_tdata_3 = s_axis_testdata

assign m_axis_tdata_1 = s_axis_testdata, m_axis_tdata_2 = s_axis_testdata, m_axis_tdata_3 = s_axis_testdata

// RTL bugs: m_axis_tdata_1 = s_axis_testdata, m_axis_tdata_2 = s_axis_testdata, m_axis_tdata_3 = s_axis_testdata

assign m_axis_tdata_1 = s_axis_testdata, m_axis_tdata_2 = s_axis_testdata, m_axis_tdata_3 = s_axis_testdata

// RTL bugs: m_axis_tdata_1 = s_axis_testdata, m_axis_tdata_2 = s_axis_testdata, m_axis_tdata_3 = s_axis_testdata

assign m_axis_tdata_1 = s_axis_testdata, m_axis_tdata_2 = s_axis_testdata, m_axis_tdata_3 = s_axis_testdata
   
endmodule