module gmii_rx_to_axi_stream (
    //GMII Input Signals:
    input wire        gmii_rx_clk,
    input wire [7:0]  gmii_rxd,
    input wire        gmii_rx_dv,

    //AXI-Stream Output Signals:
    output wire [7:0] m_axis_tdata,
    output wire       m_axis_tvalid,
    input wire        m_axis_tready,
    output wire       m_axis_tlast
);

    // State definitions
    localparam IDLE = 2'b00,
               RECEIVING = 2'b01,
               FINISHED = 2'b10;

    reg [7:0] rx_buffer = 0;
    reg [1:0] state = IDLE;

    always @(posedge gmii_rx_clk) begin
        case(state)
            IDLE: begin
                if (gmii_rx_dv) begin
                    state <= RECEIVING;
                end else begin
                    state <= IDLE;
                end
            end
            RECEIVING: begin
                rx_buffer <= {rx_buffer[6:0], gmii_rxd};
                if (~gmii_rx_dv) begin
                    state <= FINISHED;
                end
            end
            FINISHED: begin
                // Handle finished frame logic here
                state <= IDLE;
            end
        endcase
    end

    assign m_axis_tdata = rx_buffer;
    assign m_axis_tvalid = (state == RECEIVING);
    assign m_axis_tlast = (state == FINISHED);

endmodule