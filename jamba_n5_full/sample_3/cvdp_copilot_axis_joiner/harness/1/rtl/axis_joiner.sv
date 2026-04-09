module axis_joiner #(
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire [7:0] s_axis_tdata_1,
    input wire tvalid_1,
    input wire tready_1,
    input wire [7:0] s_axis_tdata_2,
    input wire tvalid_2,
    input wire tready_2,
    input wire [7:0] s_axis_tdata_3,
    input wire tvalid_3,
    input wire tready_3,
    input wire [7:0] s_axis_tdata_4? Wait, we have only 3 inputs. The problem states three independent AXI Streams: s_axis_tdata_1, s_axis_tdata_2, s_axis_tdata_3. So we have three.

    // Outputs
    output reg [7:0] m_axis_tdata,
    output reg m_axis_tvalid,
    output reg m_axis_tready,
    output reg m_axis_tlast,
    output wire m_axis_tuser,
    output wire busy
);
