Module definition
module axis_joiner(
    input clock,
    input rst,
    input s_axis_tdata_1,
    input s_axis_tvalid_1,
    input s_axis_tready_1,
    input s_axis_tlast_1,
    input s_axis_tdata_2,
    input s_axis_tvalid_2,
    input s_axis_tready_2,
    input s_axis_tlast_2,
    input s_axis_tdata_3,
    input s_axis_tvalid_3,
    input s_axis_tready_3,
    output m_axis_tdata,
    output m_axis_tvalid,
    output m_axis_tready,
    output m_axis_tlast,
    output m_axis_tuser,
    output busy
);

// FSM states
enum state_state {
    STATE_IDLE,
    STATE_1,
    STATE_2,
    STATE_3
};

// FSM
always_ff state_state fsm = {
    (rst, 1'b0) ? STATE_IDLE : fsm,
    (s_axis_tvalid_1 & !s_axis_tvalid_2 & !s_axis_tvalid_3) ? STATE_1 :
        (s_axis_tvalid_2 & !s_axis_tvalid_1 & !s_axis_tvalid_3) ? STATE_2 :
        (s_axis_tvalid_3 & !s_axis_tvalid_1 & !s_axis_tvalid_2) ? STATE_3 : fsm
};

// Buffers
reg [7:0] buffer_tdata;
reg buffer_tvalid;
reg buffer_tready;
reg buffer_tlast;
reg [1:0] buffer_tuser;

// Data selection
always logic {
    case (fsm)
        STATE_IDLE:
            if (s_axis_tvalid_1) {
                m_axis_tdata = s_axis_tdata_1;
                m_axis_tvalid = 1;
                m_axis_tuser = 0x1;
            } else if (s_axis_tvalid_2) {
                m_axis_tdata = s_axis_tdata_2;
                m_axis_tvalid = 1;
                m_axis_tuser = 0x2;
            } else if (s_axis_tvalid_3) {
                m_axis_tdata = s_axis_tdata_3;
                m_axis_tvalid = 1;
                m_axis_tuser = 0x3;
            } else {
                buffer_tdata = 0;
                buffer_tvalid = 1;
                buffer_tuser = 0;
            }
            FSM state fsm_new = fsm;
        STATE_1:
            if (s_axis_tvalid_1) {
                m_axis_tdata = s_axis_tdata_1;
                m_axis_tvalid = 1;
                m_axis_tuser = 0x1;
            } else {
                buffer_tdata = s_axis_tdata_1;
                buffer_tvalid = s_axis_tvalid_1;
                buffer_tuser = 0x1;
            }
            FSM state fsm_new = fsm;
        STATE_2:
            if (s_axis_tvalid_2) {
                m_axis_tdata = s_axis_tdata_2;
                m_axis_tvalid = 1;
                m_axis_tuser = 0x2;
            } else {
                buffer_tdata = s_axis_tdata_2;
                buffer_tvalid = s_axis_tvalid_2;
                buffer_tuser = 0x2;
            }
            FSM state fsm_new = fsm;
        STATE_3:
            if (s_axis_tvalid_3) {
                m_axis_tdata = s_axis_tdata_3;
                m_axis_tvalid = 1;
                m_axis_tuser = 0x3;
            } else {
                buffer_tdata = s_axis_tdata_3;
                buffer_tvalid = s_axis_tvalid_3;
                buffer_tuser = 0x3;
            }
            FSM state fsm_new = fsm;
    endcase
};

// Output processing
always logic {
    if (m_axis_tvalid) {
        m_axis_tready = 1;
        busy = 1;
    } else if (!m_axis_tready) {
        busy = 0;
        if (buffer_tvalid) {
            m_axis_tdata = buffer_tdata;
            m_axis_tvalid = 1;
            m_axis_tuser = buffer_tuser;
            buffer_tdata = 0;
            buffer_tvalid = 0;
        }
    }
}

endmodule