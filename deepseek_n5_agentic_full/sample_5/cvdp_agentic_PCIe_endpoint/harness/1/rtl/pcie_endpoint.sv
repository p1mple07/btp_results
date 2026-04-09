Module declaration
module pcie_endpoint(
    parameter(addr_width) = 64,
    parameter(data_width) = 128
);

// Include helper modules
#include "rtl/dma_fsm.sv"
#include "rtl/pcie_transaction_fsm.sv"
#include "rtl/pcie_data_link_fsm.sv"
#include "rtl/msi_x_fsm.sv"

// Define output ports for the entire module
output [data_width - 1:0] tx_tlp;
output [data_width - 1:0] rx_ready;
output [addr_width - 1:0]dma_address;
output [data_width - 1:0]dma_data;
output [1:0]msix_interrupt;

// Include internal FSMs
include "pciie_transaction_fsm PCIIE_TRANSACTION_FSM(addr_width, data_width)";
include "pciie_data_link_fsm PCIIE_DATA_LINK_FSM(PCIIE_TRANSACTION_FSM_state, addr_width, data_width)";
include "dma_fsm DMA_FSM(dma_request, dma_address, dma_data, dma_complete)";
include "msix_fsm MSI_X_FSM(dma_complete)";

// FSM states and initializations
PCIIE_TRANSACTION_FSM_state fsm_transaction_state = PCIIE_TRANSACTION_FSM.IDLE;
PCIIE_DATA_LINK_FSM_state fsm_data_link_state = PCIIE_DATA_LINK_FSM.IDLE;
DMA_FSM_state fsm_dma_state = DMA_FSM.IDLE;
MSIX_FSM_state fsm_msix_state = MSIX_FSM.IDLE;

// Event mapping
eventdma_request = fsm_dma_state.dma_request;
eventdma_complete = fsm_dma_state.dma_complete;

// Finalization
endmodule