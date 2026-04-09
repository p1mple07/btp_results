module axis_joiner (
    input clk,
    input rst,
    input s_axis_tdata_1,
    input s_axis_tvalid_1,
    output reg s_axis_tready_1,
    input s_axis_tlast_1,
    input s_axis_tdata_2,
    input s_axis_tvalid_2,
    output reg s_axis_tready_2,
    input s_axis_tlast_2,
    input s_axis_tdata_3,
    input s_axis_tvalid_3,
    output reg s_axis_tready_3,
    output reg m_axis_tdata,
    output reg m_axis_tvalid,
    output reg m_axis_tready,
    output reg m_axis_tlast,
    output reg [2:0] m_axis_tuser,
    output reg busy
);

    reg [7:0] temp_data;
    reg [1:0] state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 2'b00;
            temp_data <= 8'b0;
            m_axis_tready <= 1'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata <= 8'b0;
            m_axis_tlast <= 1'b0;
            m_axis_tuser <= 3'b0;
            busy <= 1'b0;
        end else begin
            case (state)
                2'b00: begin
                    if (s_axis_tvalid_1) begin
                        state <= 2'b01;
                        temp_data <= s_axis_tdata_1;
                    end else if (s_axis_tvalid_2 && !s_axis_tvalid_1) begin
                        state <= 2'b02;
                        temp_data <= s_axis_tdata_2;
                    end else if (s_axis_tvalid_3 && !s_axis_tvalid_1 && !s_axis_tvalid_2) begin
                        state <= 2'b03;
                        temp_data <= s_axis_tdata_3;
                    end
                end
                2'b01: begin
                    if (s_axis_tlast_1) begin
                        state <= 2'b00;
                        m_axis_tdata <= temp_data;
                        m_axis_tvalid <= 1'b1;
                        m_axis_tready <= 1'b0;
                        m_axis_tlast <= 1'b1;
                        m_axis_tuser <= 3'b1;
                        busy <= 1'b1;
                    end
                end
                2'b02: begin
                    if (s_axis_tlast_2) begin
                        state <= 2'b00;
                        m_axis_tdata <= temp_data;
                        m_axis_tvalid <= 1'b1;
                        m_axis_tready <= 1'b0;
                        m_axis_tlast <= 1'b1;
                        m_axis_tuser <= 3'b2;
                        busy <= 1'b1;
                    end
                end
                2'b03: begin
                    if (s_axis_tlast_3) begin
                        state <= 2'b00;
                        m_axis_tdata <= temp_data;
                        m_axis_tvalid <= 1'b1;
                        m_axis_tready <= 1'b0;
                        m_axis_tlast <= 1'b1;
                        m_axis_tuser <= 3'b3;
                        busy <= 1'b1;
                    end
                end
                default: next_state <= 2'b00;
            endcase
        end
    end

    assign m_axis_tdata = (state == 2'b01) ? temp_data : 8'b0;
    assign m_axis_tvalid = (state == 2'b01) ? 1'b1 : 1'b0;
    assign m_axis_tready = (state == 2'b01) ? 1'b1 : 1'b0;
    assign m_axis_tlast = (state == 2'b01) ? 1'b1 : 1'b0;
    assign m_axis_tuser = (state == 2'b01) ? 3'b1 : (state == 2'b02) ? 3'b2 : (state == 2'b03) ? 3'b3 : 3'b0;

    always @(posedge clk) begin
        if (rst) begin
            next_state <= 2'b00;
        end else begin
            next_state <= state;
        end
    end

endmodule
