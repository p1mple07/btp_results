module gmii_rx_to_axi_stream (
    //GMII Input Signals:
    input  wire        gmii_rx_clk,
    input  wire [7:0]  gmii_rxd,
    input  wire        gmii_rx_dv,

    //AXI-Stream Output Signals:
    output reg [7:0]   m_axis_tdata,
    output reg         m_axis_tvalid,
    input  wire        m_axis_tready,
    output reg         m_axis_tlast
);

    // State definitions
    localparam IDLE      = 2'b00,
               RECEIVING = 2'b01,
               FINISHED  = 2'b10;

    reg [1:0] state, next_state;
    reg [7:0] data_reg;
    reg       prev_dv;

    // State transition logic
    always_ff @(posedge gmii_rx_clk) begin
        // Sample previous gmii_rx_dv at the beginning of the cycle
        prev_dv <= gmii_rx_dv;
        case (state)
            IDLE: begin
                if (gmii_rx_dv) begin
                    // Start of frame: latch the first byte and move to RECEIVING state
                    data_reg   <= gmii_rxd;
                    next_state <= RECEIVING;
                end else begin
                    next_state <= IDLE;
                end
            end

            RECEIVING: begin
                if (m_axis_tready) begin
                    if (gmii_rx_dv) begin
                        // Continue receiving: update data register with new byte
                        data_reg   <= gmii_rxd;
                        next_state <= RECEIVING;
                    end else if (prev_dv) begin
                        // Falling edge detected: frame ended, move to FINISHED state
                        next_state <= FINISHED;
                    end else begin
                        next_state <= RECEIVING;
                    end
                end else begin
                    // m_axis_tready is low: still check for falling edge
                    if ((~gmii_rx_dv) && prev_dv) begin
                        next_state <= FINISHED;
                    end else begin
                        next_state <= RECEIVING;
                    end
                end
            end

            FINISHED: begin
                if (m_axis_tready)
                    next_state <= IDLE;
                else
                    next_state <= FINISHED;
            end

            default: next_state <= IDLE;
        endcase
        state <= next_state;
    end

    // Output assignment logic
    always_comb begin
        m_axis_tdata = data_reg;
        // Assert tvalid only when in RECEIVING or FINISHED state and m_axis_tready is high.
        m_axis_tvalid = ((state == RECEIVING) || (state == FINISHED)) ? m_axis_tready : 1'b0;
        // Assert tlast only in FINISHED state when m_axis_tready is high.
        m_axis_tlast  = (state == FINISHED) ? m_axis_tready : 1'b0;
    end

endmodule