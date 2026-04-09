module axis_joiner(
    input clk,
    input rst,
    input [7:0] s_axis_tdata_1,
    input s_axis_tvalid_1,
    output reg s_axis_tready_1,
    input s_axis_tlast_1,
    input [7:0] s_axis_tdata_2,
    input s_axis_tvalid_2,
    output reg s_axis_tready_2,
    input s_axis_tlast_2,
    input [7:0] s_axis_tdata_3,
    input s_axis_tvalid_3,
    output reg s_axis_tready_3,
    output [7:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready,
    output reg m_axis_tlast,
    output [2:0] m_axis_tuser
);

    // State declaration
    typedef enum logic [2:0] {
        STATE_IDLE,
        STATE_1,
        STATE_2,
        STATE_3
    } fsm_state_t;

    logic [2:0] current_state, next_state;

    // Input and output register declarations
    reg [7:0] temp_data_1, temp_data_2, temp_data_3;
    reg [1:0] tag_id_1, tag_id_2, tag_id_3;

    // Arbitration logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= STATE_IDLE;
            temp_data_1 <= 'b0;
            temp_data_2 <= 'b0;
            temp_data_3 <= 'b0;
            tag_id_1 <= 0x1;
            tag_id_2 <= 0x2;
            tag_id_3 <= 0x3;
            m_axis_tready <= 1'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast <= 1'b0;
            m_axis_tuser <= {tag_id_1, tag_id_2, tag_id_3};
        end else begin
            case (current_state)
                STATE_IDLE: begin
                    if (s_axis_tvalid_1) begin
                        current_state <= STATE_1;
                    end
                    if (s_axis_tvalid_2) begin
                        current_state <= STATE_2;
                    end
                    if (s_axis_tvalid_3) begin
                        current_state <= STATE_3;
                    end
                end
                STATE_1: begin
                    temp_data_1 <= s_axis_tdata_1;
                    if (s_axis_tlast_1) begin
                        current_state <= STATE_IDLE;
                    end
                end
                STATE_2: begin
                    temp_data_2 <= s_axis_tdata_2;
                    if (s_axis_tlast_2) begin
                        current_state <= STATE_IDLE;
                    end
                end
                STATE_3: begin
                    temp_data_3 <= s_axis_tdata_3;
                    if (s_axis_tlast_3) begin
                        current_state <= STATE_IDLE;
                    end
                end
                default: begin
                    next_state <= STATE_IDLE;
                end
            endcase
            next_state <= current_state;
        end
    end

    // Data buffering and synchronization logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            temp_data_1 <= 'b0;
            temp_data_2 <= 'b0;
            temp_data_3 <= 'b0;
            tag_id_1 <= 0x1;
            tag_id_2 <= 0x2;
            tag_id_3 <= 0x3;
        end else begin
            if (!m_axis_tready) begin
                if (current_state == STATE_1) temp_data_1 <= s_axis_tdata_1;
                if (current_state == STATE_2) temp_data_2 <= s_axis_tdata_2;
                if (current_state == STATE_3) temp_data_3 <= s_axis_tdata_3;
            end else begin
                if (current_state == STATE_1) m_axis_tdata = temp_data_1;
                if (current_state == STATE_2) m_axis_tdata = temp_data_2;
                if (current_state == STATE_3) m_axis_tdata = temp_data_3;
                m_axis_tvalid <= 1'b1;
                m_axis_tlast <= 1'b1;
                m_axis_tuser <= {tag_id_1, tag_id_2, tag_id_3};
                temp_data_1 <= 'b0;
                temp_data_2 <= 'b0;
                temp_data_3 <= 'b0;
            end
        end
    end

    // Status signal logic
    assign busy = (current_state != STATE_IDLE);

endmodule
