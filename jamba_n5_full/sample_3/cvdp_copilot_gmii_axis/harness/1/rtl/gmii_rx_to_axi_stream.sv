module gmii_rx_to_axi_stream (
    input wire gmii_rx_clk,
    input wire [7:0] gmii_rxd,
    input wire gmii_rx_dv,

    output wire [7:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,
    output wire m_axis_tlast
);

    // State machine states
    reg [2:0] state; // 0: IDLE, 1: RECEIVING, 2: FINISHED
    reg [2:0] next_state;
    reg [2:0] current_state;

    initial begin
        state = IDLE;
        next_state = 0;
        current_state = IDLE;
    end

    always @(posedge gmii_rx_clk or negedge gmii_rx_dv) begin
        if (gmii_rx_dv) begin
            current_state = IDLE;
        end else begin
            case (state)
                0: begin // IDLE
                    if (gmii_rxd[7:0] != 0) begin
                        state = RECEIVING;
                    end
                end
                1: RECEIVING => begin
                    if (gmii_rxd[7:0] == 0) begin
                        state = FINISHED;
                    end else begin
                        state = RECEIVING;
                    end
                end
                2: FINISHED => begin
                    // after finished, we can go back to idle? Or stay?
                    state = IDLE;
                end
            endcase
        end
    end

    always @(*) begin
        if (state == RECEIVING) begin
            if (gmii_rx_dv) begin
                m_axis_tvalid = 1'b1;
                m_axis_tdata[7:0] = gmii_rxd;
            end else begin
                m_axis_tvalid = 1'b0;
            end
        end else begin
            m_axis_tvalid = 1'b0;
        end
    end

    assign m_axis_tlast = m_axis_tready;

endmodule
