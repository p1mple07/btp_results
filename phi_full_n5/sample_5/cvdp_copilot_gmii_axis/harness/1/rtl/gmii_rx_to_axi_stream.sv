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
    // Input and output ports
    wire [7:0] gmii_rxd_out, m_axis_tdata_out;

    // State logic
    always @(posedge gmii_rx_clk or gmii_rx_dv) begin
        case (state_reg)
            IDLE: begin
                if (gmii_rx_dv) begin
                    state_reg <= RECEIVING;
                    gmii_rxd_out <= gmii_rxd;
                end
                m_axis_tvalid <= 0;
                m_axis_tlast <= 0;
            end
            RECEIVING: begin
                m_axis_tvalid <= 1;
                m_axis_tdata_out <= gmii_rxd_out;
                if (!gmii_rx_dv) begin
                    state_reg <= FINISHED;
                end
            end
            FINISHED: begin
                m_axis_tvalid <= 0;
                m_axis_tlast <= 1;
            end
        endcase
    end

    // Output logic
    assign m_axis_tdata = m_axis_tdata_out;
    assign m_axis_tvalid = m_axis_tvalid;
    assign m_axis_tlast = state_reg == FINISHED;

endmodule
