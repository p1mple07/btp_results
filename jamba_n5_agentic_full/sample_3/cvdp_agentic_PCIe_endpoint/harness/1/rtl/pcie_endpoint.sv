module pcie_endpoint #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 128
)(
    input wire clk,
    input wire rst_n,
    input wire [DATA_WIDTH-1:0] pcie_rx_tlp,
    input wire [DATA_WIDTH-1:0] pcie_rx_valid,
    input wire [DATA_WIDTH-1:0] pcie_rx_ready,
    output wire [DATA_WIDTH-1:0] pcie_tx_tlp,
    output wire [DATA_WIDTH-1:0] pcie_tx_valid,
    output wire [DATA_WIDTH-1:0] pcie_tx_ready,
    input wire dma_request,
    output wire dma_complete,
    input wire msix_interrupt,
    output wire msix_interrupt_active
);

reg [ADR_WIDTH-1:0] tlp_decoded_data;
reg [ADDR_WIDTH-1:0] dma_address;
reg [DATA_WIDTH-1:0] dma_data;
reg [1:0] dma_state; // idle, read_desc, fetch_data, write_dma
reg [1:0] pcie_tx_state; // idle, transmit, send_response
reg msix_pending;

always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        // reset all
        pcie_rx_tlp <= 0;
        pcie_rx_valid <= 0;
        pcie_rx_ready <= 0;
        pcie_tx_tlp <= 0;
        pcie_tx_valid <= 0;
        pcie_tx_ready <= 0;
        dma_address <= 0;
        dma_data <= 0;
        dma_state <= IDLE;
        pcie_tx_state <= IDLE;
        msix_pending <= 0;
    } else begin
        // ... rest
    end
end

always @(*) begin
    if (pcie_rx_valid && pcie_rx_ready) begin
        // decode and store in tlp_decoded_data
        tlp_decoded_data = pcie_rx_tlp;
        // trigger dma and msix?
    end
end

always @(posedge clk) begin
    if (dma_state == READ_DESC) begin
        // fetch data
        dma_data = dma_address;
        dma_address <= dma_address + 1;
        // check completion
    end
end

// etc.
