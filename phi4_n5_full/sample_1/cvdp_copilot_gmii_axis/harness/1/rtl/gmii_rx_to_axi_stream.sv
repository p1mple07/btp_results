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

    // Define a fixed frame length (number of bytes per frame)
    parameter FRAME_LENGTH = 8;

    // State and byte counter registers
    reg [1:0] state;
    reg [2:0] byte_counter;  // 3 bits are enough for FRAME_LENGTH = 8

    // Register to hold the current data word
    reg [7:0] data_reg;

    // State Machine: Synchronous process on gmii_rx_clk
    always_ff @(posedge gmii_rx_clk) begin
        case (state)
            IDLE: begin
                // Wait for gmii_rx_dv to indicate start of frame
                if (gmii_rx_dv) begin
                    state      <= RECEIVING;
                    byte_counter <= 0;
                end
            end

            RECEIVING: begin
                if (gmii_rx_dv) begin
                    // Only transfer data when downstream is ready
                    if (m_axis_tready) begin
                        data_reg <= gmii_rxd;  // Capture data
                        // If this is the last byte of the frame, prepare to finish
                        if (byte_counter == FRAME_LENGTH - 1)
                            state <= FINISHED;
                        else
                            byte_counter <= byte_counter + 1;
                    end
                end
                else begin
                    // If gmii_rx_dv goes low unexpectedly, end the frame
                    state <= FINISHED;
                end
            end

            FINISHED: begin
                // Wait until gmii_rx_dv is low to return to IDLE
                if (!gmii_rx_dv)
                    state <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end

    // AXI-Stream Output Assignments (combinational)
    assign m_axis_tdata = (state == RECEIVING && gmii_rx_dv && m_axis_tready) ? data_reg : 8'b0;
    assign m_axis_tvalid = (state == RECEIVING && gmii_rx_dv && m_axis_tready) ? 1'b1 : 1'b0;
    assign m_axis_tlast  = (state == RECEIVING && gmii_rx_dv && m_axis_tready && (byte_counter == FRAME_LENGTH - 1)) ? 1'b1 : 1'b0;

endmodule