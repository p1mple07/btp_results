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
    
    logic [7:0]         rx_buffer;
    logic                 rx_valid;
    logic                 rx_ready;
    logic                 rx_start;
    logic [15:0]        rx_counter;
    logic                 rx_first;
    logic                 rx_last;

    always @(posedge gmii_rx_clk) begin
        if (gmii_rx_dv && ~rx_valid) begin
            rx_buffer <= gmii_rxd;
            rx_valid <= 1'b1;
            rx_start <= 1'b1;
        end else if (~gmii_rx_dv) begin
            rx_valid <= 1'b0;
        end

        if (rx_ready && rx_valid) begin
            rx_ready <= 1'b0;
            rx_buffer <= {rx_buffer[6:0], gmii_rxd};
            rx_counter <= rx_counter + 1;

            if (rx_counter == 16'd16383) begin
                rx_counter <= 16'd0;
                rx_first <= 1'b1;
                rx_last <= 1'b0;
            end else if (rx_counter == 16'd16384 - 7) begin
                rx_first <= 1'b0;
                rx_last <= 1'b1;
            end else begin
                rx_first <= 1'b0;
                rx_last <= 1'b0;
            end
        end
    end

    assign m_axis_tvalid = rx_valid && ~rx_ready;
    assign m_axis_tdata = rx_valid? rx_first? rx_buffer : {rx_buffer[7:1], rx_buffer[0]} : '0;
    assign m_axis_tlast = rx_valid? rx_last : '0;

endmodule