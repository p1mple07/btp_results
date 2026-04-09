module axis_joiner #(
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst,
    input wire s_axis_tdata_1,
    input wire s_axis_tvalid_1,
    input wire s_axis_tready_1,
    input wire s_axis_tlast_1,
    input wire s_axis_tdata_2,
    input wire s_axis_tvalid_2,
    input wire s_axis_tready_2,
    input wire s_axis_tlast_2,
    input wire s_axis_tdata_3,
    input wire s_axis_tvalid_3,
    input wire s_axis_tready_3,
    input wire s_axis_tlast_3,
    input wire m_axis_tdata,
    input wire m_axis_tvalid,
    input wire m_axis_tready,
    input wire m_axis_tlast,
    input wire m_axis_tuser,
    output wire m_axis_tdata,
    output wire m_axis_tvalid,
    output wire m_axis_tready,
    output wire m_axis_tlast,
    output wire m_axis_tuser,
    output wire busy
);

reg [3:0] state;
reg [2:0] state_next;
wire ready;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= 0;
        state_next <= 0;
        ready <= 0;
        m_axis_tdata <= 0;
        m_axis_tvalid <= 0;
        m_axis_tready <= 1'b1;
        m_axis_tlast <= 1'b1;
        m_axis_tuser <= 3'b0;
        busy <= 1'b0;
    end else begin
        state_next = state;
        case (state)
            0: // IDLE
                if (s_axis_tvalid_1) begin
                    state_next = 1;
                end
                if (s_axis_tvalid_2) begin
                    state_next = 2;
                end
                if (s_axis_tvalid_3) begin
                    state_next = 3;
                end
        endcase

            1: // STATE_1
                if (s_axis_tvalid_1 && !s_axis_tready_1) begin
                    ready <= 1'b1;
                end else begin
                    ready <= 1'b0;
                end
                // ... other conditions
        endcase

        // similar for 2 and 3
    end
endalways

always @(*) begin
    if (state == 0) begin
        m_axis_tdata <= 0;
        m_axis_tvalid <= 0;
        m_axis_tready <= 1'b1;
        m_axis_tlast <= 1'b1;
        m_axis_tuser <= 3'b0;
        busy <= 1'b0;
    end else if (state == 1) begin
        // state 1: transfer from s_axis_tdata_1
        if (m_axis_tready) begin
            m_axis_tdata <= s_axis_tdata_1;
            m_axis_tvalid <= s_axis_tvalid_1;
            m_axis_tready <= 1'b0;
        end else if (m_axis_tready) begin
            m_axis_tlast <= 1'b1;
        end
        busy <= 1'b1;
    end else if (state == 2) begin
        // state 2: transfer from s_axis_tdata_2
        if (m_axis_tready) begin
            m_axis_tdata <= s_axis_tdata_2;
            m_axis_tvalid <= s_axis_tvalid_2;
            m_axis_tready <= 1'b0;
        end else if (m_axis_tready) begin
            m_axis_tlast <= 1'b1;
        end
        busy <= 1'b1;
    end else if (state == 3) begin
        // state 3: transfer from s_axis_tdata_3
        if (m_axis_tready) begin
            m_axis_tdata <= s_axis_tdata_3;
            m_axis_tvalid <= s_axis_tvalid_3;
            m_axis_tready <= 1'b0;
        end else if (m_axis_tready) begin
            m_axis_tlast <= 1'b1;
        end
        busy <= 1'b1;
    end
end

assign m_axis_tdata = (state == 1) ? s_axis_tdata_1 : (state == 2) ? s_axis_tdata_2 : (state == 3) ? s_axis_tdata_3 : 0;
assign m_axis_tvalid = (state == 1) ? s_axis_tvalid_1 : (state == 2) ? s_axis_tvalid_2 : (state == 3) ? s_axis_tvalid_3 : 0;
assign m_axis_tready = (state == 1) ? 1'b0 : (state == 2) ? 1'b0 : (state == 3) ? 1'b0 : 1'b1;
assign m_axis_tlast = (state == 1) ? 1'b1 : (state == 2) ? 1'b1 : (state == 3) ? 1'b1 : 0;
assign m_axis_tuser = (state == 1) ? 3'b0x1 : (state == 2) ? 3'b0x2 : (state == 3) ? 3'b0x3 : 3'b0;
assign busy = (state == 1) || (state == 2) || (state == 3);

endmodule
