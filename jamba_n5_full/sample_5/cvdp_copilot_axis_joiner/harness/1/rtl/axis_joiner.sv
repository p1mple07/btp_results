module axis_joiner #(
    parameter TDATA_WIDTH = 8,
    parameter TVALID_WIDTH = 1,
    parameter TLAST_WIDTH = 1,
    parameter TUUSER_WIDTH = 2
) (
    input  logic clk,
    input  logic rst,
    input  logic s_axis_tdata_1, logic s_axis_tvalid_1, logic s_axis_tready_1,
    input  logic s_axis_tdata_2, logic s_axis_tvalid_2, logic s_axis_tready_2,
    input  logic s_axis_tdata_3, logic s_axis_tvalid_3, logic s_axis_tready_3,
    input  logic s_axis_tlast_1, s_axis_tlast_2, s_axis_tlast_3,
    input  logic m_axis_tdata, logic m_axis_tvalid, logic m_axis_tready, logic m_axis_tlast,
    output  logic m_axis_tdata,
    output  logic m_axis_tvalid,
    output  logic m_axis_tready,
    output  logic m_axis_tlast,
    output  logic m_axis_tuser,
    output  logic busy,
    output  logic temp
);

// Reset
always_ff @(sensitive always [(input ~rst) | (input ~rst_n)]) begin
    if (rst)
        m_axis_tdata <= 0;
    else
        m_axis_tdata <= m_axis_tdata;
end

// Initial state
initial begin
    state <= IDLE;
end

// State machine
always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else
        case (state)
            IDLE: begin
                if (s_axis_tvalid_1) state <= STATE_1;
                else if (s_axis_tvalid_2) state <= STATE_2;
                else if (s_axis_tvalid_3) state <= STATE_3;
                else state <= IDLE;
            end
            STATE_1: begin
                if (tlast_1) begin
                    state <= IDLE;
                end
                // transfer data
                m_axis_tdata <= s_axis_tdata_1;
                m_axis_tvalid <= 1;
                m_axis_tready <= 0;
                m_axis_tlast <= 0;
                m_axis_tuser <= 0;
                busy <= 1;
                temp <= 1;
            end
            STATE_2: begin
                if (tlast_2) begin
                    state <= IDLE;
                end
                m_axis_tdata <= s_axis_tdata_2;
                m_axis_tvalid <= 1;
                m_axis_tready <= 0;
                m_axis_tlast <= 0;
                m_axis_tuser <= 1;
                busy <= 1;
                temp <= 0;
            end
            STATE_3: begin
                if (tlast_3) begin
                    state <= IDLE;
                end
                m_axis_tdata <= s_axis_tdata_3;
                m_axis_tvalid <= 1;
                m_axis_tready <= 0;
                m_axis_tlast <= 0;
                m_axis_tuser <= 2;
                busy <= 1;
                temp <= 0;
            end
        endcase
end

// Output
always @(*) begin
    if (m_axis_tready) begin
        m_axis_tdata <= m_axis_tdata;
        m_axis_tvalid <= m_axis_tvalid;
        m_axis_tready <= 0;
        m_axis_tlast <= 0;
        m_axis_tuser <= m_axis_tuser;
        busy <= 0;
        temp <= 0;
    end
end

// Busy
assign busy = (busy_prev) ? 1 : 0; // Not needed, but we can ignore.

endmodule
