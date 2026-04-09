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

    // FIFO buffer for storing received data
    wire [7:0] [57-1:0] rx_buffer; // 57 bits buffer

    // State variable
    reg state = IDLE;

    // Control signals
    wire rx_valid; // Signal to indicate when buffer has valid data

    // State transition logic
    always_posedge gmii_rx_clk begin
        case(state)
            IDLE:
                // On first data valid, start receiving
                if(gmii_rx_dv) begin
                    state = RECEIVING;
                    rx_valid = 1;
                end
                else
                    state = IDLE;
                end

            RECEIVING:
                // Shift incoming data into buffer
                if(gmii_rx_dv) begin
                    // Shift in new data bit
                    rx_buffer[56] = gmii_rxd[7];
                    // Check if buffer is full
                    if(rx_valid) begin
                        // If buffer is full, send data out
                        m_axis_tvalid = 1;
                        m_axis_tlast = 1;
                        // Shift out data bit
                        m_axis_tdata[7] = rx_buffer[0];
                        // Prepare buffer for next frame
                        rx_buffer[55:0] = rx_buffer[56:1];
                        // Set ready for next frame
                        m_axis_tready = 1;
                        state = IDLE;
                    end
                end
                else
                    // If buffer is empty, transition to finished state
                    state = FINISHED;
                end

            FINISHED:
                // Wait for new frame
                if(!gmii_rx_dv) begin
                    state = IDLE;
                end
        endcase
    end

    // Set tready when in IDLE state
    always @* begin
        if(state == IDLE)
            m_axis_tready = 1;
    end

    // Set tvalid and tlast when sending data
    always @* begin
        if(state == IDLE && m_axis_tready)
            m_axis_tvalid = 1;
    end
    // Always set tlast when finishing a frame
    always @* begin
        if(state == IDLE)
            m_axis_tlast = 0;
    end
endmodule