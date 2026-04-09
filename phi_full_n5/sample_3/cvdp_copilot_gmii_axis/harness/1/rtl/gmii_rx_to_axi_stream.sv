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
    // State output logic
    always @(posedge gmii_rx_clk or posedge gmii_rx_dv) begin
        if (gmii_rx_dv) begin
            state_reg <= RECEIVING;
            m_axis_tdata <= gmii_rxd;
            m_axis_tvalid <= 1;
        end
        else if (state_reg == IDLE) begin
            state_reg <= RECEIVING;
            m_axis_tvalid <= 1;
        end
        else if (state_reg == RECEIVING) begin
            if (m_axis_tready) begin
                state_reg <= FINISHED;
                m_axis_tlast <= 1;
            end
            else begin
                m_axis_tvalid <= 1;
            end
        end
    end

    // AXI-Stream output logic
    assign m_axis_tdata = (state_reg == RECEIVING) ? gmii_rxd : 8'bz;
    assign m_axis_tvalid = (state_reg == RECEIVING) ? 1 : 0;
    assign m_axis_tlast = (state_reg == FINISHED) ? 1 : 0;

endmodule
