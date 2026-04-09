module gmii_rx_to_axi_stream (
    // GMII Input Signals:
    input  wire        gmii_rx_clk,
    input  wire [7:0]  gmii_rxd,
    input  wire        gmii_rx_dv,

    // AXI-Stream Output Signals:
    output wire [7:0]  m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tlast
);

    // State definitions
    localparam IDLE      = 2'b00,
               RECEIVING = 2'b01,
               FINISHED  = 2'b10;

    reg [1:0] state;
    reg [7:0] data_reg;
    // tvalid and tlast are derived from state and m_axis_tready

    // State machine: clocked by gmii_rx_clk
    always @(posedge gmii_rx_clk) begin
        case (state)
            IDLE: begin
                // Wait for start of frame indicated by gmii_rx_dv
                if (gmii_rx_dv) begin
                    data_reg <= gmii_rxd;  // Capture the first byte
                    state    <= RECEIVING;
                end
            end
            RECEIVING: begin
                // Only transfer when downstream is ready
                if (m_axis_tready) begin
                    if (gmii_rx_dv) begin
                        // Still receiving: update data_reg with current gmii_rxd
                        data_reg <= gmii_rxd;
                        state    <= RECEIVING;
                    end else begin
                        // gmii_rx_dv dropped: end of frame detected
                        state <= FINISHED;
                    end
                end
                // If m_axis_tready is low, hold state and data_reg
            end
            FINISHED: begin
                // Wait for handshake completion before returning to IDLE
                if (m_axis_tready) begin
                    state <= IDLE;
                end
            end
            default: state <= IDLE;
        endcase
    end

    // Output assignments:
    // m_axis_tdata always reflects the current data to be sent.
    assign m_axis_tdata = data_reg;

    // m_axis_tvalid is asserted only when data is available and the downstream is ready.
    // According to the spec, tvalid is de-asserted if m_axis_tready is low.
    assign m_axis_tvalid = (((state == RECEIVING) || (state == FINISHED)) && m_axis_tready);

    // m_axis_tlast is asserted only in the FINISHED state to indicate end-of-frame.
    assign m_axis_tlast = (state == FINISHED);

endmodule