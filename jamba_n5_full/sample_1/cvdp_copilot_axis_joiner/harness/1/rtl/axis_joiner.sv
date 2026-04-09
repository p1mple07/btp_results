module axis_joiner (
    input  clk,
    input  rst_n,
    input  s_axis_tdata_1 [7:0], s_axis_tvalid_1, s_axis_tready_1,
    input  s_axis_tdata_2 [7:0], s_axis_tvalid_2, s_axis_tready_2,
    input  s_axis_tdata_3 [7:0], s_axis_tvalid_3, s_axis_tready_3,
    input  m_axis_tdata [7:0], m_axis_tvalid, m_axis_tready,
    input  m_axis_tlast,
    output reg m_axis_tdata [7:0],
    output reg m_axis_tvalid,
    output reg m_axis_tready,
    output reg m_axis_tlast,
    output reg m_axis_tuser [1:0],
    output wire busy
);

reg  [3:0] state; // IDLE, STATE_1, STATE_2, STATE_3
reg state_next;
wire ready;

always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        state <= 0;
        state_next <= 0;
        m_axis_tdata[7:0] <= {8'b0};
        m_axis_tvalid <= 0;
        m_axis_tready <= 0;
        m_axis_tlast <= 1'b0;
        m_axis_tuser <= 2'b0;
        busy <= 0;
    } else begin
        state_next = state + 1;
        state_next <= state_next ^ 4'd3; // cycle through states
    end
end

always @(*) begin
    case (state)
        0: begin
            if (s_axis_tvalid_1 && !s_axis_tready_1) begin
                state_next = 1;
            end else begin
                state_next = 0;
            end
        end
        1: begin
            if (s_axis_tvalid_2 && !s_axis_tready_2) begin
                state_next = 2;
            end else if (!s_axis_tvalid_1) begin
                state_next = 1;
            end else begin
                state_next = 0;
            end
        end
        2: begin
            if (s_axis_tvalid_3 && !s_axis_tready_3) begin
                state_next = 3;
            end else if (!s_axis_tvalid_2) begin
                state_next = 2;
            end else begin
                state_next = 0;
            end
        end
        3: begin
            if (s_axis_tvalid_1 && !s_axis_tready_1) begin
                state_next = 0;
            end else if (!s_axis_tvalid_3) begin
                state_next = 3;
            end else begin
                state_next = 0;
            end
        end
    endcase
end

always @(state_next) begin
    state <= state_next;
end

assign ready = state == 1 ? 1 : 0;

always @(combine) begin
    m_axis_tdata = {s_axis_tdata_1[7:0], s_axis_tdata_2[7:0], s_axis_tdata_3[7:0]};
    m_axis_tvalid = s_axis_tvalid_1 | s_axis_tvalid_2 | s_axis_tvalid_3;
    m_axis_tready = s_axis_tready_1 | s_axis_tready_2 | s_axis_tready_3;
    m_axis_tlast = s_axis_tlast_1 | s_axis_tlast_2 | s_axis_tlast_3;
    m_axis_tuser = m_axis_tvalid;
    m_axis_tdata[7:0] = {s_axis_tdata_1[7:0], s_axis_tdata_2[7:0], s_axis_tdata_3[7:0]};
    m_axis_tready = s_axis_tready_1 | s_axis_tready_2 | s_axis_tready_3;
    m_axis_tlast = s_axis_tlast_1 | s_axis_tlast_2 | s_axis_tlast_3;
    m_axis_tuser = m_axis_tvalid;
end

always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        state <= 0;
        state_next <= 0;
        m_axis_tdata[7:0] <= {8'b0};
        m_axis_tvalid <= 0;
        m_axis_tready <= 0;
        m_axis_tlast <= 1'b0;
        m_axis_tuser <= 2'b0;
        busy <= 0;
    } else begin
        if (s_axis_tvalid_1 && !s_axis_tready_1) begin
            s_axis_tdata_1 <= m_axis_tdata[7:0];
            s_axis_tvalid_1 <= 1;
            s_axis_tready_1 <= 1;
        end else if (s_axis_tvalid_2 && !s_axis_tready_2) begin
            s_axis_tdata_2 <= m_axis_tdata[7:0];
            s_axis_tvalid_2 <= 1;
            s_axis_tready_2 <= 1;
        end else if (s_axis_tvalid_3 && !s_axis_tready_3) begin
            s_axis_tdata_3 <= m_axis_tdata[7:0];
            s_axis_tvalid_3 <= 1;
            s_axis_tready_3 <= 1;
        end else begin
            s_axis_tdata_1 <= 8'b0;
            s_axis_tvalid_1 <= 0;
            s_axis_tready_1 <= 0;
            s_axis_tdata_2 <= 8'b0;
            s_axis_tvalid_2 <= 0;
            s_axis_tready_2 <= 0;
            s_axis_tdata_3 <= 8'b0;
            s_axis_tvalid_3 <= 0;
            s_axis_tready_3 <= 0;
        end
    end
end

always @(*) begin
    busy = (s_axis_tready_1 | s_axis_tready_2 | s_axis_tready_3);
end

endmodule
