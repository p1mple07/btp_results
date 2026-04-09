module gmii_rx_to_axi_stream (
    input wire gmii_rx_clk,
    input wire [7:0] gmii_rxd,
    input wire gmii_rx_dv,
    output wire [7:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,
    output wire m_axis_tlast
);

    reg state;
    reg [1:0] next_state;

    initial begin
        state = IDLE;
        next_state = IDLE;
    end

    always @(comb) begin
        case (state)
            IDLE: begin
                if (gmii_rx_dv) begin
                    next_state = RECEIVING;
                end else begin
                    next_state = IDLE;
                end
            end
            RECEIVING: begin
                if (gmii_rxd) begin
                    m_axis_tvalid = 1;
                    m_axis_tdata = gmii_rxd;
                end
                next_state = FINISHED;
            end
            FINISHED: begin
                m_axis_tvalid = 0;
                m_axis_tdata = 0;
                m_axis_tready = 0;
                state = IDLE;
            end
        endcase
    end

    assign m_axis_tvalid = m_axis_tvalid;
    assign m_axis_tready = m_axis_tready;
    assign m_axis_tlast = m_axis_tlast;

endmodule
