module axis_joiner(
    input clock,
    input rst,
    input [7:0] s_axis_tdata_1,
    input [1:0] s_axis_tvalid_1,
    input [1:0] s_axis_tready_1,
    input [0:0] s_axis_tlast_1,
    input [7:0] s_axis_tdata_2,
    input [1:0] s_axis_tvalid_2,
    input [1:0] s_axis_tready_2,
    input [0:0] s_axis_tlast_2,
    input [7:0] s_axis_tdata_3,
    input [1:0] s_axis_tvalid_3,
    input [1:0] s_axis_tready_3,
    input [0:0] s_axis_tlast_3,
    output [7:0] m_axis_tdata,
    output [1:0] m_axis_tvalid,
    output [1:0] m_axis_tready,
    output [0:0] m_axis_tlast,
    output [1:2] m_axis_tuser,
    output busy
);

    // FSM states
    state
        idle,
        state_1,
        state_2,
        state_3
    endstate;

    // State variables
    always @* begin
        case (s_axis_tvalid_1 | s_axis_tvalid_2 | s_axis_tvalid_3)
            // Priority: 1 > 2 > 3
            if (s_axis_tvalid_1) next_state = state_1;
            else if (s_axis_tvalid_2) next_state = state_2;
            else if (s_axis_tvalid_3) next_state = state_3;
            else next_state = idle;
        endcase
    endalways

    // Data buffers
    reg [7:0] data1, data2, data3;
    reg [1:0] valid1, valid2, valid3;
    reg [0:0] last1, last2, last3;

    // Current state
    state current_state = idle;

    // Output signals
    always @* begin
        case (current_state)
            idle:
                m_axis_tdata = 0;
                m_axis_tvalid = 0;
                m_axis_tready = 0;
                m_axis_tlast = 0;
                busy = 0;
                data1 = 0;
                data2 = 0;
                data3 = 0;
                valid1 = 0;
                valid2 = 0;
                valid3 = 0;
                last1 = 0;
                last2 = 0;
                last3 = 0;
                break;
            state_1:
                if (s_axis_tvalid_1) begin
                    m_axis_tdata = s_axis_tdata_1;
                    m_axis_tvalid = 1;
                    m_axis_tready = 1;
                    m_axis_tlast = 0;
                    m_axis_tuser = 0x1;
                    busy = 1;
                    // Wait for tlast
                    data1 = s_axis_tdata_1;
                    valid1 = 1;
                    last1 = 0;
                    next_state = idle;
                    break;
                end
            state_2:
                if (s_axis_tvalid_2) begin
                    m_axis_tdata = s_axis_tdata_2;
                    m_axis_tvalid = 1;
                    m_axis_tready = 1;
                    m_axis_tlast = 0;
                    m_axis_tuser = 0x2;
                    busy = 1;
                    data2 = s_axis_tdata_2;
                    valid2 = 1;
                    last2 = 0;
                    next_state = idle;
                    break;
                end
            state_3:
                if (s_axis_tvalid_3) begin
                    m_axis_tdata = s_axis_tdata_3;
                    m_axis_tvalid = 1;
                    m_axis_tready = 1;
                    m_axis_tlast = 0;
                    m_axis_tuser = 0x3;
                    busy = 1;
                    data3 = s_axis_tdata_3;
                    valid3 = 1;
                    last3 = 0;
                    next_state = idle;
                    break;
                end
        endcase
    endalways

    // Output m_axis_tdata
    wire m_axis_tdata = (current_state == idle) ? 0 : (current_state == state_1 ? data1 : (current_state == state_2 ? data2 : data3));

    // Output m_axis_tvalid
    wire m_axis_tvalid = (current_state == idle) ? 0 : 1;

    // Output m_axis_tready
    wire m_axis_tready = (current_state == idle) ? 0 : 1;

    // Output m_axis_tlast
    wire m_axis_tlast = (current_state == idle) ? 0 : 0;

    // Output m_axis_tuser
    wire m_axis_tuser = (current_state == idle) ? 0 : (current_state == state_1 ? 0x1 : (current_state == state_2 ? 0x2 : 0x3));

    // Output busy
    wire busy = (current_state != idle);

endmodule