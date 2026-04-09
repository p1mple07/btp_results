module axi_tap #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter TIMEOUT_THRESHOLD = 1000
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
    input  [ADDR_WIDTH-1:0]   inport_araddr_i,
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
    input  [1:0]    outport_peripheral0_bresp_i,
    input           outport_peripheral0_bvalid_i,
    output          outport_peripheral0_bready_o,
    // Read Address Channel (AR)
    input           outport_peripheral0_arready_i,
    output          outport_peripheral0_arvalid_o,
    output [ADDR_WIDTH-1:0]   outport_peripheral0_araddr_o,
    // Read Data Channel (R)
    input           outport_peripheral0_rready_i,
    output          outport_peripheral0_rvalid_o,
    input  [DATA_WIDTH-1:0]   outport_peripheral0_rdata_i,
    input  [1:0]    outport_peripheral0_rresp_i,
    output          outport_peripheral0_rready_o,

    // Timeout-related ports
    input           timeout_threshold_i,
    reg timeout_timer,
    reg timeout_flag,
    reg timeout_stopped = 0;

    // Additional always blocks for timeout detection
    always @ (posedge clk_i) begin
        // Read timeout detection
        if (rst_i) begin
            timeout_timer = 0;
            timeout_flag = 0;
        end else if (inport_arvalid_i && inport_arready_o) begin
            timeout_timer = 0;
            timeout_flag = 0;
        end else if (!inport_arvalid_i || !inport_arready_o) begin
            if (timeout_timer == TIMEOUT_THRESHOLD) begin
                timeout_flag = 1;
            end
            timeout_timer = 0;
        end

        // Write timeout detection
        if (rst_i) begin
            timeout_timer = 0;
            timeout_flag = 0;
        end else if (inport_awvalid_i && inport_awready_o) begin
            timeout_timer = 0;
            timeout_flag = 0;
        end else if (!inport_awvalid_i || !inport_awready_o) begin
            if (timeout_timer == TIMEOUT_THRESHOLD) begin
                timeout_flag = 1;
            end
            timeout_timer = 0;
        end
    end

    wire timeout_timer <= timeout_timer + 1'd1;
    assign timeout_flag = timeout_flag & (~timeout_stopped);
    reg timeout_stopped;

    // Assign outputs with timeout handling
    assign inport_arready_o  = read_accept_w       && inport_arready_i;
    assign inport_rvalid_o   = inport_rvalid_i;

    assign outport_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd0);
    assign outport_araddr_o  = inport_araddr_i;
    assign outport_rready_o  = inport_rready_i;

    assign outport_peripheral0_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd1);
    assign outport_peripheral0_araddr_o  = inport_araddr_i;
    assign outport_peripheral0_rready_o  = inport_rready_i;

    // Add timeout handling logic to outputs
    assign outport_arvalid_o = outport_arvalid_o & ~timeout_flag;
    assign outport_rvalid_o = outport_rvalid_o & ~timeout_flag;
    assign outport_peripheral0_arvalid_o = outport_peripheral0_arvalid_o & ~timeout_flag;
    assign outport_peripheral0_rvalid_o = outport_peripheral0_rvalid_o & ~timeout_flag;