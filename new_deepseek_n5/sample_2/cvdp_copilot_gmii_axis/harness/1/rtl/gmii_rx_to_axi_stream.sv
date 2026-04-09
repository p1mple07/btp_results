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

    reg    current_state = IDLE;
    reg [7:0] buffer = 0;
    reg     valid_data = 0;

    always @ (gmii_rx_dv or gmii_rx_clk) begin
        case (current_state)
            IDLE:
                // Initial state
                if (gmii_rx_dv) begin
                    current_state = RECEIVING;
                    valid_data = 0;
                end
            RECEIVING:
                // Accumulate 8-bit data
                valid_data = (valid_data << 1) + gmii_rxd;
                
                // Check for next rx_dv
                if (gmii_rx_dv) begin
                    current_state = IDLE;
                    // Set tlast when finished receiving frame
                    m_axis_tlast = 1;
                    // Transfer accumulated data
                    m_axis_tdata = valid_data;
                    // Set tvalid when data is available
                    if (valid_data != 0) begin
                        m_axis_tvalid = 1;
                    end
                    // Set tready when downstream is ready
                    m_axis_tready = 0;
                end
            FINISHED:
                // Do nothing in this state
                // m_axis_tvalid remains inactive until data arrives
        endcase
    end

endmodule