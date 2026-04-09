Module declaration
module rtl::pciexpress::pcie_endpoint(
    parameter address_width = 64,
    parameter data_width = 128
);

// Top level port list definition
 Port ( 
    input clock,
    input rst_n,
    output reg [data_width-1:0] tlp_decoded_data,
    output reg [data_width-1:0] tlp_valid,
    input reg [addr_width-1:0] dma_address,
    input reg [data_width-1:0] dma_data,
    output reg dma_start,
    output reg [1:0] msix_interrupt,
    input wire [data_width-1:0] pciex_tx_tlp,
    input wire [1:0] pciex_tx_valid,
    input wire [1:0] pciex_tx_ready,
    input wire [data_width-1:0] pciex_rx_tlp,
    input wire [1:0] pciex_rx_valid,
    input wire [1:0] pciex_rx_ready
 );

// Internal signals
 reg [data_width-1:0] tlp_valid_reg;
 reg [addr_width-1:0] dma_address_reg;
 reg [data_width-1:0] dma_data_reg;
 reg dma_start_reg;
 // FSM states
 reg [7:0] fsm_state;

// Define the Finite State Machines here
 fsm_state fsm_pcie_transaction_fsm;
 fsm_state fsm_pci_ex_link_fsm;
 fsm_state fsm_dma_fsm;
 fsm_state fsm_msi_x_fsm;

endmodule