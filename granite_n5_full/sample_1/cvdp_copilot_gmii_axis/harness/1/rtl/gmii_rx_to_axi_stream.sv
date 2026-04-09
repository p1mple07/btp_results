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

    // Register to store current state
    reg [1:0] state;

    // Register to store incoming byte count
    reg [7:0] byte_count;

    // Register to store received data bytes
    reg [7:0] data_reg;

    // Register to store next byte count
    reg [7:0] next_byte_count;

    // Register to store next byte to be sent
    reg [7:0] next_byte_reg;

    // Register to track current byte index
    reg [1:0] byte_index;

    always @(posedge gmii_rx_clk) begin
        case(state)
            IDLE: begin
                if (gmii_rx_dv == 1'b1) begin
                    state <= RECEIVING;
                    byte_count <= gmii_rxd[6];
                    data_reg <= {gmii_rxd[5], gmii_rxd[4]};
                    next_byte_count <= gmii_rxd[3:0];
                    next_byte_reg <= gmii_rxd[7:2];
                    byte_index <= 2'b00;
                end
            end

            RECEIVING: begin
                data_reg <= {data_reg[5:0], gmii_rxd[5:0]};
                byte_index <= byte_index + 1;

                if (byte_index == byte_count) begin
                    if (next_byte_count!= 0) begin
                        next_byte_reg <= {next_byte_reg[7:0], gmii_rxd[7:0]};
                        state <= RECEIVING;
                    end else begin
                        state <= FINISHED;
                    end
                end
            end

            FINISHED: begin
                // Do nothing
            end
        endcase
    end

    assign m_axis_tdata = (state == IDLE)? 8'h00 : ((state == RECEIVING)? data_reg : next_byte_reg);
    assign m_axis_tvalid = (state == IDLE)? 1'b0 : 1'b1;
    assign m_axis_tready = 1'b1;
    assign m_axis_tlast = (state == FINISHED)? 1'b1 : 1'b0;

endmodule