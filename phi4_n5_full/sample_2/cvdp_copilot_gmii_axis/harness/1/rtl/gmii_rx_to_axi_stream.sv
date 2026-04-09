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
    localparam IDLE     = 2'b00,
               RECEIVING = 2'b01,
               FINISHED  = 2'b10;

    // Parameter to define frame length (number of bytes per frame)
    parameter FRAME_LENGTH = 8;

    // Registers for state machine and byte counting
    reg [1:0] state;
    reg [3:0] byte_count;  // 4-bit counter (sufficient for FRAME_LENGTH=8)

    // Registers to hold data and control signals
    reg [7:0] data_reg;
    reg       tvalid_reg;
    reg       tlast_reg;

    // Output assignments
    assign m_axis_tdata  = data_reg;
    assign m_axis_tvalid = tvalid_reg;
    assign m_axis_tlast  = tlast_reg;

    // Main state machine: driven by gmii_rx_clk
    always @(posedge gmii_rx_clk) begin
        case (state)
            IDLE: begin
                // Wait for the start of frame indicated by gmii_rx_dv
                if (gmii_rx_dv) begin
                    state         <= RECEIVING;
                    byte_count    <= 0;
                    data_reg      <= gmii_rxd; // capture first byte
                    tvalid_reg    <= 1'b1;
                    tlast_reg     <= 1'b0;
                end else begin
                    tvalid_reg    <= 1'b0;
                    tlast_reg     <= 1'b0;
                end
            end

            RECEIVING: begin
                if (gmii_rx_dv) begin
                    // When gmii_rx_dv is valid, check if downstream is ready
                    if (m_axis_tready) begin
                        // Transfer the current byte and prepare for the next
                        data_reg      <= gmii_rxd; // load next byte
                        byte_count    <= byte_count + 1;
                        // Assert tlast when the final byte is reached
                        if (byte_count == FRAME_LENGTH - 1) begin
                            tlast_reg   <= 1'b1;
                            state       <= FINISHED;
                        end else begin
                            tlast_reg   <= 1'b0;
                        end
                    end else begin
                        // If downstream not ready, de-assert tvalid as specified
                        tvalid_reg   <= 1'b0;
                    end
                end else begin
                    // gmii_rx_dv deasserted: end-of-frame detected
                    state         <= FINISHED;
                    tlast_reg     <= 1'b1;
                end
            end

            FINISHED: begin
                // Wait for downstream to be ready to flush the final tlast signal
                if (m_axis_tready) begin
                    state         <= IDLE;
                    tvalid_reg    <= 1'b0;
                    tlast_reg     <= 1'b0;
                end
            end

            default: state <= IDLE;
        endcase
    end

endmodule