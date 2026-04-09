interface
  input clocks.clk;
  input clocks.rst_n;

  // PCIe interface
  input PCIeInterface.pcie_rx_tlp addr_width;
  input PCIeInterface.pcie_rx_valid;
  output PCIeInterface.pcie_rx_ready;

  output PCIeInterface.pcie_tx_tlp data_width;
  output PCIeInterface.pcie_tx_valid;
  input PCIeInterface.pcie_tx_ready;

  // DMA interface
  input wires.dma_request;
  output wires.dma_complete;

  // MSI-X interface
  output wires.msix_interrupt;
endinterface