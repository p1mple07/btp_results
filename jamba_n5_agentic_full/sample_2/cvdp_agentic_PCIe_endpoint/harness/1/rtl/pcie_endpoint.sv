module pcie_endpoint #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 128
) (
    input clk,
    input rst_n,
    input pcie_rx_tlp,
    input pcie_rx_valid,
    output pcie_rx_ready,
    input pcie_tx_tlp,
    output pcie_tx_valid,
    output pcie_tx_ready,
    input dma_request,
    input dma_complete,
    input msix_interrupt,
    output msix_interrupt,
    output msec_complete,
    output tlp_valid,
    output tlp_ready,
    output dma_start,
    output dma_complete,
    output msix_interrupt
);

    // Internal signals
    reg [ADDR_WIDTH-1:0] tlp_decoded_data;
    reg [DATA_WIDTH-1:0] dma_data;
    reg dma_start;
    reg dma_complete;
    reg msix_interrupt;
    reg [2:0] tlp_ready;
    reg [2:0] dma_complete;
    reg [2:0] msec_complete;

    // States
    localparam STATE_IDLE = 2'b00;
    localparam STATE_RECEIVE = 2'b01;
    localparam STATE_PROCESS = 2'b10;
    localparam STATE_SEND_RESPONSE = 2'b11;

    reg [2:0] current_state;
    reg current_pcie_rx_ready;
    reg current_pcie_tx_valid;
    reg current_dma_complete;
    reg current_msix_interrupt;

    initial begin
        current_state = STATE_IDLE;
        current_pcie_rx_ready = 0;
        current_pcie_tx_valid = 0;
        current_dma_complete = 0;
        current_msix_interrupt = 0;
    end

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            current_state <= STATE_IDLE;
            current_pcie_rx_ready <= 0;
            current_pcie_tx_valid <= 0;
            current_dma_complete <= 0;
            current_msix_interrupt <= 0;
        end else begin
            case (current_state)
                STATE_IDLE: begin
                    if (pcie_rx_valid) begin
                        current_state = STATE_RECEIVE;
                        current_pcie_rx_ready = 1;
                    end else begin
                        current_state = STATE_IDLE;
                    end
                end
                STATE_RECEIVE: begin
                    if (pcie_rx_valid) begin
                        current_state = STATE_PROCESS;
                        tlp_decoded_data <= pcie_rx_tlp;
                    end
                end
                STATE_PROCESS: begin
                    if (pcie_tx_tlp) begin
                        current_state = STATE_SEND_RESPONSE;
                        pcie_tx_ready <= 1;
                    end else begin
                        current_state = STATE_PROCESS;
                    end
                end
                STATE_SEND_RESPONSE: begin
                    if (pcie_tx_ready) begin
                        current_state = STATE_IDLE;
                        pcie_tx_valid <= 1;
                    end
                end
            endcase
        end
    end

    // DMA FSM
    always @(current_state) begin
        case (current_state)
            STATE_IDLE: begin
                if (dma_request) begin
                    dma_start <= 1;
                end
            end
            STATE_PROCESS: begin
                if (dma_complete) begin
                    dma_complete <= 0;
                    dma_start <= 0;
                end
            end
            STATE_SEND_RESPONSE: begin
                if (dma_complete) begin
                    dma_complete <= 0;
                end
            end
        endcase
    end

    // MSI-X FSM
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            msix_interrupt <= 0;
        end else begin
            if (msix_interrupt) begin
                msix_interrupt <= 0;
                // simulate one clock cycle delay
                dma_complete <= 1;
                dma_complete <= 0;
                // generate interrupt
                msix_interrupt <= 1;
                msix_interrupt <= 0;
            end
        end
    end

    assign pcie_rx_ready = current_pcie_rx_ready;
    assign pcie_tx_valid = current_pcie_tx_valid;
    assign pcie_tx_ready = current_pcie_tx_ready;
    assign dma_complete = current_dma_complete;
    assign msix_interrupt = current_msix_interrupt;
    assign tlp_valid = current_tlp_valid;
    assign tlp_ready = current_tlp_ready;
    assign dma_start = current_dma_start;
    assign dma_complete = current_dma_complete;
    assign msix_interrupt = current_msix_interrupt;

endmodule
