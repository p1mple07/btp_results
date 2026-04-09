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

    // State reg
    reg state = IDLE;

    // Bit count reg
    reg bit_count = 0;

    // Case statement
    case (state)
        IDLE:
            if (gmii_rx_dv) begin
                state = RECEIVING;
            end
        RECEIVING:
            if (gmii_rx_dv) begin
                state = FINISHED;
                bit_count = 0;
            else begin
                bit_count = bit_count + 1;
                if (bit_count == 8) begin
                    state = FINISHED;
                end
                m_axis_tvalid = 1;
                if (m_axis_tready == 0) begin
                    m_axis_tvalid = 0;
                end
            end
        FINISHED:
            // Do nothing until next frame
    endcase

    // Output data
    m_axis_tdata = gmii_rxd;

    // End of frame
    m_axis_tlast = 1;

endmodule