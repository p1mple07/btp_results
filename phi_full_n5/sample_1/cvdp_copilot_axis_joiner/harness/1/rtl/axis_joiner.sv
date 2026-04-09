module axis_joiner #(
    parameter DATA_WIDTH = 8,
    parameter TAG_ID_WIDTH = 2
) (
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] s_axis_tdata_1,
    input s_axis_tvalid_1,
    output reg s_axis_tready_1,
    input s_axis_tlast_1,
    input [DATA_WIDTH-1:0] s_axis_tdata_2,
    input s_axis_tvalid_2,
    output reg s_axis_tready_2,
    input s_axis_tlast_2,
    input [DATA_WIDTH-1:0] s_axis_tdata_3,
    input s_axis_tvalid_3,
    output reg s_axis_tready_3,
    output [DATA_WIDTH-1:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready,
    output reg m_axis_tlast,
    output [TAG_ID_WIDTH-1:0] m_axis_tuser,
    output reg busy
);

    reg [DATA_WIDTH-1:0] temp_data;
    reg [DATA_WIDTH-1:0] temp_tdata;
    reg [DATA_WIDTH-1:0] temp_tvalid;
    reg temp_tlast;
    reg [TAG_ID_WIDTH-1:0] temp_tag_id;

    // State declaration
    typedef enum logic [DATA_WIDTH-1:0] {STATE_IDLE, STATE_1, STATE_2, STATE_3} state_t;
    state_t current_state, next_state;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= STATE_IDLE;
            m_axis_tvalid <= 0;
            temp_data <= 0;
            temp_tdata <= 0;
            temp_tvalid <= 0;
            temp_tlast <= 0;
            temp_tag_id <= 0;
            busy <= 0;
        end else begin
            case (current_state)
                STATE_IDLE:
                    if (s_axis_tvalid_1) begin
                        current_state <= STATE_1;
                        temp_tdata <= s_axis_tdata_1;
                        temp_tvalid <= s_axis_tvalid_1;
                        temp_tlast <= s_axis_tlast_1;
                        temp_tag_id <= TAG_ID_1;
                    end else if (s_axis_tvalid_2 && !s_axis_tvalid_1) begin
                        current_state <= STATE_2;
                        temp_tdata <= s_axis_tdata_2;
                        temp_tvalid <= s_axis_tvalid_2;
                        temp_tlast <= s_axis_tlast_2;
                        temp_tag_id <= TAG_ID_2;
                    end else if (s_axis_tvalid_3 && !s_axis_tvalid_1 && !s_axis_tvalid_2) begin
                        current_state <= STATE_3;
                        temp_tdata <= s_axis_tdata_3;
                        temp_tvalid <= s_axis_tvalid_3;
                        temp_tlast <= s_axis_tlast_3;
                        temp_tag_id <= TAG_ID_3;
                    end
                    next_state <= STATE_IDLE;
            STATE_1:
                m_axis_tdata <= temp_tdata;
                m_axis_tvalid <= temp_tvalid;
                m_axis_tlast <= temp_tlast;
                m_axis_tuser <= temp_tag_id;
                temp_tdata <= 0;
                temp_tvalid <= 0;
                temp_tlast <= 0;
                temp_tag_id <= 0;
                busy <= 1;
                next_state <= STATE_IDLE;
            STATE_2:
                m_axis_tdata <= temp_tdata;
                m_axis_tvalid <= temp_tvalid;
                m_axis_tlast <= temp_tlast;
                m_axis_tuser <= temp_tag_id;
                temp_tdata <= 0;
                temp_tvalid <= 0;
                temp_tlast <= 0;
                temp_tag_id <= 0;
                busy <= 1;
                next_state <= STATE_IDLE;
            STATE_3:
                m_axis_tdata <= temp_tdata;
                m_axis_tvalid <= temp_tvalid;
                m_axis_tlast <= temp_tlast;
                m_axis_tuser <= temp_tag_id;
                temp_tdata <= 0;
                temp_tvalid <= 0;
                temp_tlast <= 0;
                temp_tag_id <= 0;
                busy <= 1;
                next_state <= STATE_IDLE;
            default:
                next_state <= current_state;
            endcase
        end
        current_state <= next_state;
    end

    // Mux for output signals
    always @(*) begin
        m_axis_tdata = (current_state == STATE_1) ? temp_tdata :
                       (current_state == STATE_2) ? temp_tdata :
                       temp_tdata;
        m_axis_tvalid = (current_state == STATE_1) ? temp_tvalid :
                         (current_state == STATE_2) ? temp_tvalid :
                         temp_tvalid;
        m_axis_tlast = (current_state == STATE_1) ? temp_tlast :
                       (current_state == STATE_2) ? temp_tlast :
                       temp_tlast;
        m_axis_tuser = (current_state == STATE_1) ? temp_tag_id :
                       (current_state == STATE_2) ? temp_tag_id :
                       temp_tag_id;
    end

    // Reset logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            busy <= 0;
            temp_data <= 0;
            temp_tdata <= 0;
            temp_tvalid <= 0;
            temp_tlast <= 0;
            temp_tag_id <= 0;
        end
    end

endmodule
