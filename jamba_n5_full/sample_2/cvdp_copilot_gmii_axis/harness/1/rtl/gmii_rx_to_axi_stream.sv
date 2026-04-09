module gmii_rx_to_axi_stream (
    input wire gmii_rx_clk,
    input wire [7:0] gmii_rxd,
    input wire gmii_rx_dv,

    output wire [7:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,
    output wire m_axis_tlast
);

    localparam IDLE = 2'b00, RECEIVING = 2'b01, FINISHED = 2'b10;

    always @(gmii_rx_clk) begin
        case (state)
        IDLE: begin
            if (gmii_rx_dv) begin
                state <= RECEIVING;
            end
        end
        RECEIVING: begin
            always @(comb) begin
                m_axis_tdata[7:0] = gmii_rxd;
                m_axis_tvalid = 1'b1;
                m_axis_tready = 1'b1;
            end
        end
        FINISHED: begin
            m_axis_tvalid = 1'b0;
            m_axis_tready = 1'b1;
            m_axis_tlast = 1'b1;
        end
        endcase
    end

endmodule
