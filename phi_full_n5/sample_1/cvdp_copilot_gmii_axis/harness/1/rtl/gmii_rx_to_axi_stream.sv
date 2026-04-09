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
    // Output logic
    assign m_axis_tdata = (state_reg == RECEIVING) ? gmii_rxd : 8'b0;
    assign m_axis_tvalid = (state_reg == RECEIVING) && gmii_rx_dv;
    assign m_axis_tlast = (state_reg == FINISHED);

    // State transition logic
    always @(posedge gmii_rx_clk or gmii_rx_dv) begin
        case (state_reg)
            IDLE:
                if (gmii_rx_dv) begin
                    state_reg <= RECEIVING;
                end
            RECEIVING:
                if (!gmii_rx_dv) begin
                    state_reg <= FINISHED;
                end
            FINISHED:
                state_reg <= IDLE;
            default:
                state_reg <= IDLE;
        endcase
    end

endmodule
