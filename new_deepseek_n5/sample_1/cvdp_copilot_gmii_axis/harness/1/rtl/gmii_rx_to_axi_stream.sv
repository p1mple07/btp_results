module gmii_rx_to_axi_stream (
    input wire        gmii_rx_clk,
    input wire [7:0]  gmii_rxd,
    input wire        gmii_rx_dv,
    output wire [7:0] m_axis_tdata,
    output wire       m_axis_tvalid,
    input wire        m_axis_tready,
    output wire       m_axis_tlast
);

    localparam IDLE = 2'b00,
               RECEIVING = 2'b01,
               FINISHED = 2'b10;

    // State definitions
    reg    state = IDLE;

    // State transition logic
    always_ff @(gmii_rx_clk) begin
        if (gmii_rx_dv) begin
            state = RECEIVING;
        else begin
            if (state == IDLE) begin
                state = FINISHED;
            end
        end
    end

    // Processing logic in RECEIVER state
    always @(gmii_rx_clk) begin
        if (state ==_RECEIVING) begin
            m_axis_tvalid = 1;
            m_axis_tdata[7:0] = gmii_rxd;
            if (gmii_rxd == 0) begin
                m_axis_tlast = 1;
            end
            m_axis_tready = 0;
        else begin
            m_axis_tvalid = 0;
            m_axis_tdata[7:0] = 0;
            m_axis_tlast = 0;
        end
    end
endmodule