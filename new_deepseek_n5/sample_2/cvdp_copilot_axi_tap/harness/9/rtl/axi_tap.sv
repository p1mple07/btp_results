module axi_tap #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter TIMEOUT_THRESHOLD = 8  // configurable timeout in cycles
)(
    input           clk_i,
    input           rst_i,
    input           inport_awvalid_i,
    input  [ADDR_WIDTH-1:0]   inport_awaddr_i,
    output          inport_awready_o,
    // Master Write Address Channel (AW)
    input           inport_wvalid_i,
    input  [DATA_WIDTH-1:0]   inport_wdata_i,
    input  [3:0]    inport_wstrb_i,
    output          inport_wready_o,
    // Master Write Response Channel (B)
    input           inport_bvalid_i,
    input  [1:0]    inport_bresp_i,
    output          inport_bready_o,
    // Master Read Address Channel (AR)
    input           inport_arvalid_i,
    input  [ADDR_WIDTH-1:0]   inport_araddr_i,
    output          inport_rvalid_o,
    // Master Read Data Channel (R)
    input           inport_rvalid_i,
    input  [DATA_WIDTH-1:0]   inport_rdata_i,
    input  [1:0]    inport_rresp_i,
    output          inport_rready_o,
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
    output          outport_peripheral0_rvalid_i,
    output [DATA_WIDTH-1:0]   outport_peripheral0_rdata_i,
    output [1:0]    outport_peripheral0_rresp_i,
    // Peripheral 0 interface
    // Write Address Channel (AW)
    input           outport_peripheral0_awvalid_o,
    output          outport_peripheral0_awready_o,
    output [ADDR_WIDTH-1:0]   outport_peripheral0_awaddr_o,
    // Write Data Channel (W)
    input           outport_peripheral0_wvalid_o,
    output          outport_peripheral0_wready_o,
    output [DATA_WIDTH-1:0]   outport_peripheral0_wdata_o,
    output [3:0]    outport_peripheral0_wstrb_o,
    // Write Response Channel (B)
    input           outport_peripheral0_bvalid_o,
    output          outport_peripheral0_bready_o,
    output [1:0]    outport_peripheral0_bresp_o,
    // Read Address Channel (AR)
    input           outport_peripheral0_arvalid_o,
    output          outport_peripheral0_arready_o,
    output [ADDR_WIDTH-1:0]   outport_peripheral0_araddr_o,
    // Read Data Channel (R)
    input           outport_peripheral0_rvalid_o,
    output          outport_peripheral0_rready_o,
    output [DATA_WIDTH-1:0]   outport_peripheral0_rdata_o,
    output [1:0]    outport_peripheral0_rresp_o,
    // Timeout Flag
    output          timeout_flag
    // Timeout Timer
    reg [3:0] timeout_read_tmr = 0;
    reg [3:0] timeout_write_tmr = 0;
    // Timeout Detection Logic
    always @posedge clk_i begin
        case (rst_i)
            timeout_read_tmr <= 0;
            timeout_write_tmr <= 0;
        endcase
    end
    // Read Timeout Detection
    always @posedge clk_i begin
        if (inport_arvalid_i && inport_arready_o) begin
            timeout_read_tmr <= timeout_read_tmr + 1;
            if (timeout_read_tmr >= TIMEOUT_THRESHOLD) begin
                timeout_flag = 1;
            end
        end
    end
    // Write Timeout Detection
    always @posedge clk_i begin
        if (inport_awvalid_i && inport_awready_o) begin
            timeout_write_tmr <= timeout_write_tmr + 1;
            if (timeout_write_tmr >= TIMEOUT_THRESHOLD) begin
                timeout_flag = 1;
            end
        end
    end
    // Reset Timeout Timer
    always @posedge clk_i begin
        case (rst_i)
            timeout_read_tmr <= 0;
            timeout_write_tmr <= 0;
        endcase
    end
    // Connect timeout_flag to peripheral outputs
    assign outport_peripheral0_rready_o = timeout_flag;
    assign outport_peripheral0_bready_o = timeout_flag;