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

    reg [7:0] frame_buffer;
    reg [15:0] frame_length;
    reg [1:0] state;

    always @(posedge gmii_rx_clk) begin
        case(state)
            IDLE: begin
                if(gmii_rx_dv == 1'b1) begin
                    frame_buffer <= gmii_rxd;
                    frame_length <= 0;
                    state <= RECEIVING;
                end
            end
            RECEIVING: begin
                frame_length <= frame_length + 16'd1;
                if(frame_length > 64'd1536) begin
                    state <= FINISHED;
                end
            end
            FINISHED: begin
                m_axis_tvalid <= 1'b0;
                state <= IDLE;
            end
        endcase
    end

    assign m_axis_tdata = (state == RECEIVING)? frame_buffer : 8'hFF;
    assign m_axis_tvalid = (state == RECEIVING)? 1'b1 : 1'b0;
    assign m_axis_tlast = ((state == FINISHED) && (frame_length < 1536))? 1'b1 : 1'b0;

endmodule