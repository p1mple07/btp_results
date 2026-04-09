module axi_tap #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter TIMEOUT_THRESHOLD = 1000 // configurable timeout
)(
    // Global Ports
    input           clk_i,
    input           rst_i,

    // Master Write Address Channel (AW)
    input           inport_awvalid_i,
    input  [ADDR_WIDTH-1:0]   inport_awaddr_i,
    output          inport_awready_o,
    // Master Write Data Channel (W)
    input           inport_wvalid_i,
    input  [DATA_WIDTH-1:0]   inport_wdata_i,
    input  [3:0]    inport_wstrb_i,
    output          inport_wready_o,
    // Master Write Response Channel (B)
    input           inport_bready_i,
    output          inport_bvalid_o,
    output [1:0]    inport_bresp_o,
    // Master Read Address Channel (AR)
    input           inport_arvalid_i,
    input           inport_araddr_i,
    output          inport_arready_o,
    // Master Read Data Channel (R)
    input           inport_rready_i,
    output          inport_rvalid_o,
    output [DATA_WIDTH-1:0]   inport_rdata_o,
    output [1:0]    inport_rresp_o,

    // Peripheral 0 interface
    // Write Address Channel (AW)
    input           outport_peripheral0_awready_i,
    output          outport_peripheral0_awvalid_o,
    output [ADDR_WIDTH-1:0]   outport_peripheral0_awaddr_o,
    // Write Data Channel (W)
    input           outport_peripheral0_wready_i,
    output          outport_peripheral0_wvalid_o,
    output [DATA_WIDTH-1:0]   outport_peripheral0_wdata_o,
    output [3:0]    outport_peripheral0_wstrb_o,
    // Write Response Channel (B)
    input           outport_peripheral0_bready_i,
    output          outport_peripheral0_bvalid_o,
    output [1:0]    outport_peripheral0_bresp_o,
    // Read Address Channel (AR)
    input           outport_peripheral0_arready_i,
    output          outport_peripheral0_arvalid_o,
    output [ADDR_WIDTH-1:0]   outport_peripheral0_araddr_o,
    // Read Data Channel (R)
    input           outport_peripheral0_rready_i,
    output          outport_peripheral0_rvalid_o,
    input  [DATA_WIDTH-1:0]   outport_peripheral0_rdata_i,
    input  [1:0]    outport_peripheral0_rresp_i,
    // Default AXI outport
    // Write Address Channel (AW)
    input           outport_awready_i,
    output          outport_awvalid_o,
    output [ADDR_WIDTH-1:0]   outport_awaddr_o,
    // Write Data Channel (W)
    input           outport_wready_i,
    output          outport_wvalid_o,
    output [DATA_WIDTH-1:0]   outport_wdata_o,
    output [3:0]    outport_wstrb_o,
    // Write Response Channel (B)
    input           outport_bvalid_i,
    input  [1:0]    outport_bresp_i,
    output          outport_bready_o,

    // Timeout-related variables
    reg [4'b0111] timeout_read_timer; // 4-bit counter for read timeout
    reg [4'b0111] timeout_write_timer; // 4-bit counter for write timeout
    reg timeout_flag = 0; // Timeout detection flag
    reg [4'b0000] timeout_read_state; // State of read timeout
    reg [4'b0000] timeout_write_state; // State of write timeout

    // Always blocks for timeout detection
    always @ (posedge clk_i)
    begin
        // Read timeout detection
        if (inport_arvalid_i && inport_araddr_i == PERIPH0_ADDR) 
            timeout_read_timer = timeout_read_timer + 1;
        else 
            timeout_read_timer = 0;
        end

        if (timeout_read_timer >= TIMEOUT_THRESHOLD)
            timeout_flag = 1;
        end

        // Write timeout detection
        if (inport_awvalid_i && inport_awaddr_i == PERIPH0_ADDR) 
            timeout_write_timer = timeout_write_timer + 1;
        else 
            timeout_write_timer = 0;
        end

        if (timeout_write_timer >= TIMEOUT_THRESHOLD)
            timeout_flag = 1;
        end
    end

    // Error handling for timeout
    always @ (posedge clk_i)
    begin
        case (timeout_flag)
            1:
                // Handle timeout here
                // Example: Abort transaction
                inport_arvalid_i = 0;
                inport_araddr_i = 0;
                inport_rvalid_o = 0;
                inport_rdata_o = 0;
                inport_rresp_o = 0;
                timeout_flag = 0;
                break;
    end
endmodule