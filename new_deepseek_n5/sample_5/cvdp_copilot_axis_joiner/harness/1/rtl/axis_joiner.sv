// Module Name: axis_joiner
// Description: Joins three AXI Stream inputs into a single output using round-robin arbitration

// Input ports
input clock;
input rst;
input [7:0] s_axis_tdata_1;
input [7:0] s_axis_tvalid_1;
input [7:0] s_axis_tready_1;
input [7:0] s_axis_tlast_1;
input [7:0] s_axis_tdata_2;
input [7:0] s_axis_tvalid_2;
input [7:0] s_axis_tready_2;
input [7:0] s_axis_tlast_2;
input [7:0] s_axis_tdata_3;
input [7:0] s_axis_tvalid_3;
input [7:0] s_axis_tready_3;

// Output ports
output [7:0] m_axis_tdata;
output [7:0] m_axis_tvalid;
output [7:0] m_axis_tready;
output [7:0] m_axis_tlast;
output [7:0] m_axis_tuser;
output busy;

// FSM states
enum state {
    IDLE,
    STATE_1,
    STATE_2,
    STATE_3
};

// Module internals
reg [7:0] m_axis_tuser;
reg [7:0] m_axis_tdata Buffers[3];
reg [7:0] m_axis_tvalid Buffers[3];
reg [7:0] m_axis_tready Buffers[3];
reg [7:0] m_axis_tlast Buffers[3];
reg [7:0] current_tdata;
reg [7:0] current_tvalid;
reg [7:0] current_tlast;
reg [7:0] current_tuser;
reg state current_state;

// FSM logic
always_ff @(posedge clock or negedge rst) begin
    case(current_state)
        IDLE:
            if (s_axis_tvalid_1) begin
                current_state = STATE_1;
                current_tdata = s_axis_tdata_1;
                current_tvalid = 1;
                current_tlast = 0;
                current_tuser = 0x1;
            end else if (s_axis_tvalid_2) begin
                current_state = STATE_2;
                current_tdata = s_axis_tdata_2;
                current_tvalid = 1;
                current_tlast = 0;
                current_tuser = 0x2;
            end else if (s_axis_tvalid_3) begin
                current_state = STATE_3;
                current_tdata = s_axis_tdata_3;
                current_tvalid = 1;
                current_tlast = 0;
                current_tuser = 0x3;
            end else
                current_state = IDLE;
    STATE_1:
        if (current_tvalid) begin
            m_axis_tdata = current_tdata;
            m_axis_tvalid = 1;
            m_axis_tready = 1;
            m_axis_tlast = 0;
            m_axis_tuser = current_tuser;
            current_tvalid = 0;
        end else if (current_tlast) begin
            current_state = IDLE;
        end
    STATE_2:
        if (current_tvalid) begin
            m_axis_tdata = current_tdata;
            m_axis_tvalid = 1;
            m_axis_tready = 1;
            m_axis_tlast = 0;
            m_axis_tuser = current_tuser;
            current_tvalid = 0;
        end else if (current_tlast) begin
            current_state = IDLE;
        end
    STATE_3:
        if (current_tvalid) begin
            m_axis_tdata = current_tdata;
            m_axis_tvalid = 1;
            m_axis_tready = 1;
            m_axis_tlast = 0;
            m_axis_tuser = current_tuser;
            current_tvalid = 0;
        end else if (current_tlast) begin
            current_state = IDLE;
        end
    default:
        current_state = IDLE;
    endcase
end