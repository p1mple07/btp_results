module axis_joiner(
    input clock,
    input rst,
    input [7:0] s_axis_tdata_1,
    input s_axis_tvalid_1,
    output s_axis_tready_1,
    input s_axis_tlast_1,
    input [7:0] s_axis_tdata_2,
    input s_axis_tvalid_2,
    output s_axis_tready_2,
    input s_axis_tlast_2,
    input [7:0] s_axis_tdata_3,
    input s_axis_tvalid_3,
    output s_axis_tready_3,
    output [7:0] m_axis_tdata,
    output s_axis_tvalid,
    output s_axis_tready,
    output s_axis_tlast,
    output [1:0] s_axis_tuser,
    output busy
);

    // FSM states
    enum FSMState {
        IDLE,
        STATE_1,
        STATE_2,
        STATE_3
    };

    // FSM state
    FSMState fsm_state = IDLE;
    // Current input data
    reg [7:0] data;
    // Tags for source streams
    s_axis_tuser = 0b00;

    // FSM transition logic
    always clock begin
        case(fsm_state)
            IDLE:
                if (s_axis_tvalid_1) begin
                    fsm_state = STATE_1;
                    data = s_axis_tdata_1;
                    s_axis_tuser = 0b01;
                end
                else if (s_axis_tvalid_2) begin
                    fsm_state = STATE_2;
                    data = s_axis_tdata_2;
                    s_axis_tuser = 0b10;
                end
                else if (s_axis_tvalid_3) begin
                    fsm_state = STATE_3;
                    data = s_axis_tdata_3;
                    s_axis_tuser = 0b11;
                end
                else begin
                    fsm_state = IDLE;
                end
            STATE_1:
                if (s_axis_tlast_1) begin
                    fsm_state = IDLE;
                    busy = 1;
                end else begin
                    busy = 0;
                end
                data = s_axis_tdata_1;
                s_axis_tuser = 0b01;
            STATE_2:
                if (s_axis_tlast_2) begin
                    fsm_state = IDLE;
                    busy = 1;
                end else begin
                    busy = 0;
                end
                data = s_axis_tdata_2;
                s_axis_tuser = 0b10;
            STATE_3:
                if (s_axis_tlast_3) begin
                    fsm_state = IDLE;
                    busy = 1;
                end else begin
                    busy = 0;
                end
                data = s_axis_tdata_3;
                s_axis_tuser = 0b11;
        end

        // Mux to select output data
        case(fsm_state)
            IDLE:
                m_axis_tdata = 0;
                s_axis_tvalid = 0;
                s_axis_tready = 0;
                s_axis_tlast = 0;
                s_axis_tuser = 0;
                busy = 0;
                break;
            STATE_1:
                m_axis_tdata = data;
                s_axis_tvalid = 1;
                s_axis_tready = 1;
                s_axis_tlast = s_axis_tlast_1;
                s_axis_tuser = 0b01;
                busy = 1;
                break;
            STATE_2:
                m_axis_tdata = data;
                s_axis_tvalid = 1;
                s_axis_tready = 1;
                s_axis_tlast = s_axis_tlast_2;
                s_axis_tuser = 0b10;
                busy = 1;
                break;
            STATE_3:
                m_axis_tdata = data;
                s_axis_tvalid = 1;
                s_axis_tready = 1;
                s_axis_tlast = s_axis_tlast_3;
                s_axis_tuser = 0b11;
                busy = 1;
                break;
        end

        // Reset initialization
        initial begin
            fsm_state = IDLE;
            busy = 0;
            m_axis_tdata = 0;
            s_axis_tvalid = 0;
            s_axis_tready = 0;
            s_axis_tlast = 0;
            s_axis_tuser = 0;
        end
    end
endmodule