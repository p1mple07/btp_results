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
    output reg [7:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready,
    output reg m_axis_tlast,
    output [1:0] m_axis_tuser
);

    // Internal signals
    reg [7:0] temp_data;
    reg [1:0] temp_tag_id;
    reg [1:0] state;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            temp_data <= 0;
            temp_tag_id <= 2'b00;
        end else begin
            case (state)
                0: begin
                    if (s_axis_tvalid_1) begin
                        state <= 1;
                        temp_tag_id <= TAG_ID_1;
                    end
                end
                1: begin
                    s_axis_tready_1 <= ~s_axis_tready_1;
                    temp_data <= s_axis_tdata_1;
                    temp_tag_id <= TAG_ID_1;
                    state <= 2;
                end
                2: begin
                    if (s_axis_tvalid_2 && ~s_axis_tvalid_1) begin
                        state <= 3;
                        temp_tag_id <= TAG_ID_2;
                    end
                end
                3: begin
                    s_axis_tready_3 <= ~s_axis_tready_3;
                    temp_data <= s_axis_tdata_3;
                    temp_tag_id <= TAG_ID_3;
                    state <= 0;
                end
                default: state <= 0;
            endcase
        end
    end

    // Output logic
    always @(posedge clk) begin
        if (s_axis_tready_1) begin
            m_axis_tdata <= temp_data;
            m_axis_tvalid <= s_axis_tvalid_1;
            m_axis_tlast <= s_axis_tlast_1;
            m_axis_tuser <= temp_tag_id;
            s_axis_tready_1 <= ~s_axis_tready_1;
        end

        if (s_axis_tready_2 && ~s_axis_tready_1) begin
            m_axis_tdata <= temp_data;
            m_axis_tvalid <= s_axis_tvalid_2;
            m_axis_tlast <= s_axis_tlast_2;
            m_axis_tuser <= temp_tag_id;
            s_axis_tready_2 <= ~s_axis_tready_2;
        end

        if (s_axis_tready_3 && ~s_axis_tready_2) begin
            m_axis_tdata <= temp_data;
            m_axis_tvalid <= s_axis_tvalid_3;
            m_axis_tlast <= s_axis_tlast_3;
            m_axis_tuser <= temp_tag_id;
            s_axis_tready_3 <= ~s_axis_tready_3;
        end

        if (m_axis_tready && ~(m_axis_tvalid || m_axis_tlast)) begin
            busy <= 1;
        end else begin
            busy <= 0;
        end
    end

    // Initialization logic for reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            m_axis_tdata <= 0;
            m_axis_tvalid <= 0;
            m_axis_tlast <= 0;
            m_axis_tuser <= 2'b00;
            busy <= 0;
        end
    end

endmodule

`define TAG_ID_1 0x1
`define TAG_ID_2 0x2
`define TAG_ID_3 0x3
