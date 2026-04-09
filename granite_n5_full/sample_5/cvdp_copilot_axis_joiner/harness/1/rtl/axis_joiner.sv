module axis_joiner (
    // Clock and Reset
    input wire clk,
    input wire rst,
    
    // Input Ports
    input wire [7:0] s_axis_tdata_1,
    input wire s_axis_tvalid_1,
    input wire s_axis_tready_1,
    input wire s_axis_tlast_1,
    input wire [7:0] s_axis_tdata_2,
    input wire s_axis_tvalid_2,
    input wire s_axis_tready_2,
    input wire s_axis_tlast_2,
    input wire [7:0] s_axis_tdata_3,
    input wire s_axis_tvalid_3,
    input wire s_axis_tready_3,
    input wire s_axis_tlast_3,
    
    // Output Ports
    output wire m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,
    output wire m_axis_tlast,
    output wire [1:0] m_axis_tuser
);

    // Your implementation goes here...
    
endmodule