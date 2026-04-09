Module declaration
module rtllib_pcie_endpoint (
    // Port declarations
    input clock,
    input rst_n,
    output tlp_decoded_data,
    output tlp_valid
);

// Parameters
parameter ADDR_WIDTH = 64;
parameter DATA_WIDTH = 128;

// States
state state = IDLE;

// State declarations
state WAITressing, TXValid, WAITReply;

// State management
always clock_edge clock #+1 do
    case(state)
        IDLE:
            if ($posedge rst_n)
                state = WAITressing;
            else 
                wait;
        WAITressing:
            if (rst_n)
                state = IDLE;
            else 
                if ($posedge $clk)
                    state = TXValid;
        TXValid:
            if ($posedge $clk && $input PCIe_tx_ready) 
                state = WAITReply;
        WAITReply:
            if ($posedge $clk && $input PCIe_tx_valid)
                state = IDLE;
        default:
            error "Unexpected state";
    endcase
end

// Instantiate modules
module top_level.pciextx
    parameter addr_width = ADDR_WIDTH;
    parameter data_width = DATA_WIDTH;
    input clock;
    input rst_n;
    output tlp_decoded_data;
    output tlp_valid;
endmodule

module top_level.pciexrx
    parameter addr_width = ADDR_WIDTH;
    parameter data_width = DATA_WIDTH;
    input clock;
    input rst_n;
    output tlp_decoded_data;
    output tlp_valid;
endmodule

module top_level.dma
    parameter addr_width = ADDR_WIDTH;
    parameter data_width = DATA_WIDTH;
    input clock;
    input rst_n;
    output dma_address;
    output dma_data;
    output dma_start;
endmodule

module top_level.mpi_impi msix_fsm
    input clock;
    input rst_n;
    output tlp_decoded_data;
    output tlp_valid;
endmodule

// Always blocks
always clock_edge clock #+1 do
    // State machine logic
    if (state == WAITressing)
        top_level.pciextx #(.addr_width(addr_width)) (.data_width(data_width)) 
            .clk(clock) 
            .rst(rst_n)
            .output.tlp_decoded_data(tlp_decoded_data) 
            .output.tlp_valid(tlp_valid);
    
    if (state == TXValid)
        top_level.pciexrx #(.addr_width(addr_width)) (.data_width(data_width))
            .clk(clock)
            .rst(rst_n)
            .output.tlp_decoded_data(tlp_decoded_data)
            .output.tlp_valid(tlp_valid);
    
    if (state == WAITReply)
        top_level.dma #(.addr_width(addr_width)) (.data_width(data_width))
            .clk(clock)
            .rst(rst_n)
            .output.da_dma_address(dma_address)
            .output.da_dma_data(dma_data)
            .output.da_dma_start(dma_start);
    
    if (state == IDLE)
        top_level.mpi_impi #(.clk(clock)) (.rst(rst_n)) 
            .output.tlp_decoded_data(tlp_decoded_data)
            .output.tlp_valid(tlp_valid);
    
end

// End module declaration
endmodule