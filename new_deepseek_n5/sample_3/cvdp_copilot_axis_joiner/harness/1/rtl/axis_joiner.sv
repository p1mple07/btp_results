module axis_joiner(
    input clock,
    input rst,
    input [7:0] s_axis_tdata_1,
    input [1:0] s_axis_tvalid_1,
    output [7:0] s_axis_tready_1,
    input [7:0] s_axis_tlast_1,
    input [7:0] s_axis_tdata_2,
    input [1:0] s_axis_tvalid_2,
    output [1:0] s_axis_tready_2,
    input [7:0] s_axis_tlast_2,
    input [7:0] s_axis_tdata_3,
    input [1:0] s_axis_tvalid_3,
    output [1:0] s_axis_tready_3,
    output [7:0] m_axis_tdata,
    output [1:0] m_axis_tvalid,
    output [1:0] m_axis_tready,
    output [7:0] m_axis_tlast,
    output [1:0] m_axis_tuser
);

    // State variables
    reg state = IDLE;
    reg [2:0] buffer_reg1 = 0;
    reg [2:0] buffer_reg2 = 0;
    reg [2:0] buffer_reg3 = 0;
    reg [7:0] temp_reg1 = 0;
    reg [7:0] temp_reg2 = 0;
    reg [7:0] temp_reg3 = 0;
    reg [7:0] current_data = 0;

    // FSM process
    always_ff @* begin
        case (state)
            IDLE:
                if (s_axis_tvalid_1) begin
                    state = STATE_1;
                    current_data = s_axis_tdata_1;
                    temp_reg1 = 0;
                    temp_reg2 = 0;
                    temp_reg3 = 0;
                end else if (s_axis_tvalid_2) begin
                    state = STATE_2;
                    current_data = s_axis_tdata_2;
                    temp_reg1 = 0;
                    temp_reg2 = 0;
                    temp_reg3 = 0;
                end else if (s_axis_tvalid_3) begin
                    state = STATE_3;
                    current_data = s_axis_tdata_3;
                    temp_reg1 = 0;
                    temp_reg2 = 0;
                    temp_reg3 = 0;
                end else begin
                    state = IDLE;
                end
            STATE_1:
                if (s_axis_tlast_1) begin
                    state = IDLE;
                    m_axis_tvalid = 1;
                    m_axis_tready = 1;
                    m_axis_tdata = current_data;
                    m_axis_tuser = 0x1;
                end else begin
                    temp_reg1 = current_data;
                    temp_reg2 = 0;
                    temp_reg3 = 0;
                end
            STATE_2:
                if (s_axis_tlast_2) begin
                    state = IDLE;
                    m_axis_tvalid = 1;
                    m_axis_tready = 1;
                    m_axis_tdata = current_data;
                    m_axis_tuser = 0x2;
                end else begin
                    temp_reg2 = current_data;
                    temp_reg1 = 0;
                    temp_reg3 = 0;
                end
            STATE_3:
                if (s_axis_tlast_3) begin
                    state = IDLE;
                    m_axis_tvalid = 1;
                    m_axis_tready = 1;
                    m_axis_tdata = current_data;
                    m_axis_tuser = 0x3;
                end else begin
                    temp_reg3 = current_data;
                    temp_reg1 = 0;
                    temp_reg2 = 0;
                end
            default:
                state = IDLE;
        endcase
    end

    // Assign outputs
    m_axis_tdata = temp_reg1;
    m_axis_tvalid = 0;
    m_axis_tready = 0;
    m_axis_tlast = 0;
    m_axis_tuser = 0;

    // Reset handling
    always rstbegin
        state = IDLE;
        m_axis_tvalid = 0;
        m_axis_tready = 0;
        m_axis_tlast = 0;
        temp_reg1 = 0;
        temp_reg2 = 0;
        temp_reg3 = 0;
    end
    always rstend

endmodule