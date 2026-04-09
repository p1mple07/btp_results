module gmii_rx_to_axi_stream (
    input wire        gmii_rx_clk,
    input wire [7:0]  gmii_rxd,
    input wire        gmii_rx_dv,
    output wire [7:0] m_axis_tdata,
    output wire       m_axis_tvalid,
    input wire        m_axis_tready,
    output wire       m_axis_tlast
);

    // State definitions
    localparam IDLE = 2'b00,
               RECEIVING = 2'b01,
               FINISHED = 2'b10;

    // State register
    reg [2:0] state_reg = IDLE;
    reg [7:0] data_reg = '0;

    // State transition logic
    always @(posedge gmii_rx_clk or gmii_rx_dv) begin
        case (state_reg)
            IDLE:
                if (gmii_rx_dv) begin
                    state_reg = RECEIVING;
                    data_reg = gmii_rxd;
                end
            RECEIVING:
                if (!gmii_rx_dv) begin
                    state_reg = FINISHED;
                    m_axis_tdata <= data_reg;
                    m_axis_tvalid = 1'b1;
                end
            FINISHED:
                if (m_axis_tready) begin
                    state_reg = IDLE;
                    m_axis_tvalid = 1'b0;
                end
        endcase
    end

    // AXI-Stream signaling
    assign m_axis_tready = (state_reg == FINISHED) && m_axis_tready;
    assign m_axis_tlast = (state_reg == FINISHED) ? 1'b1 : 1'b0;

endmodule
