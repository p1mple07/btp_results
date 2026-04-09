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

    logic [7:0] data_reg;
    logic tvalid_reg, tlast_reg;
    logic [1:0] state_reg;

    always @(posedge gmii_rx_clk or posedge gmii_rx_dv) begin
        if (gmii_rx_dv == 1'b1) begin
            case (state_reg)
                IDLE: begin
                    data_reg <= gmii_rxd;
                    state_reg <= RECEIVING;
                end
                RECEIVING: begin
                    data_reg <= {gmii_rxd, data_reg};
                    if (data_reg[7] == 1'b1) begin
                        state_reg <= FINISHED;
                    end else begin
                        state_reg <= RECEIVING;
                    end
                end
                FINISHED: begin
                    state_reg <= IDLE;
                    tlast_reg <= 1'b1;
                end
            endcase
        end
    end

    assign tvalid_reg = (state_reg!= IDLE);
    assign m_axis_tdata = data_reg;
    assign m_axis_tvalid = tvalid_reg;
    assign m_axis_tlast = tlast_reg;

endmodule