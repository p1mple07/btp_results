module pcie_endpoint #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 128
) (
    input clk,
    input rst_n,
    input pcie_rx_tlp,
    input pcie_rx_valid,
    input pcie_rx_ready,
    input pcie_tx_tlp,
    input pcie_tx_valid,
    input pcie_tx_ready,
    input dma_request,
    input dma_complete,
    input msix_interrupt,
    output tlp_decoded_data,
    output tlp_valid,
    output dma_address,
    output dma_data,
    output dma_start,
    output msis_interrupt
);

// ... implementation

endmodule
