module axi_tap #(
    parameter ADDR_WIDTH = 32, // Width of AXI4-Lite Address
    parameter DATA_WIDTH = 32, // Width of AXI4-Lite Data
    parameter TIMEOUT_THRESHOLD = 1000  // Timeout threshold in cycles (configurable)
)(
    // Global Ports
    input           clk_i,
    input           rst_i,
    input           timeout_threshold_i, // New port for timeout threshold

    // Transaction Status
    output reg timeout_flag_o; // New output for timeout flag

    // Global Inputs
    input           inport_awvalid_i,
    input           inport_arvalid_i,
    input           inport_wvalid_i,

    // Master Write Address Channel (AW)
    input           inport_awvalid_q,
    input  [ADDR_WIDTH-1:0]   inport_awaddr_i,
    output          inport_awready_o,
    input  [DATA_WIDTH-1:0]   inport_wdata_i,
    input  [3:0]    inport_wstrb_i,
    output          inport_wready_o,
    input           inport_bvalid_i,
    output [1:0]    inport_bresp_i,
    output          inport_bready_o,

    // Master Read Address Channel (AR)
    input           inport_arvalid_i,
    input  [ADDR_WIDTH-1:0]   inport_araddr_i,
    output          inport_arready_o,
    output [DATA_WIDTH-1:0]   inport_rdata_o,
    output [1:0]    inport_rresp_o,

    // Peripheral 0 interface
    input           inport_peripheral0_awvalid_i,
    output          inport_peripheral0_awready_o,
    output [ADDR_WIDTH-1:0]   inport_peripheral0_awaddr_i,
    output          inport_peripheral0_wvalid_o,
    output [DATA_WIDTH-1:0]   inport_peripheral0_wdata_i,
    output [3:0]    inport_peripheral0_wstrb_i,
    input           inport_peripheral0_bvalid_i,
    output          inport_peripheral0_bready_o,
    output [1:0]    inport_peripheral0_rresp_i,
    input           inport_peripheral0_rvalid_i,
    output          inport_peripheral0_rdata_i,
    output          inport_peripheral0_rready_o

    // Transaction Status
    output reg timeout_flag_o; // New output for timeout flag

    //-----------------------------------------------------------------
    // AXI: Read
    //-----------------------------------------------------------------
    reg [3:0]              read_pending_q;
    reg [3:0]              read_pending_r;
    reg [`ADDR_SEL_W-1:0]  read_port_q;
    reg [`ADDR_SEL_W-1:0]  read_port_r;

    always @*
    begin
        read_pending_r = read_pending_q;

        if (read_incr_w && !read_decr_w)
            read_pending_r = read_pending_r + 4'd1;
        else if (!read_incr_w && read_decr_w)
            read_pending_r = read_pending_r - 4'd1;
    end

    always @ (posedge clk_i )
    begin
        if (rst_i)
            read_pending_q <= 4'b0;
        else
            read_pending_q <= read_pending_r;

        // Read command accepted
        if (inport_araddr_i & `PERIPH0_MASK) == `PERIPH0_ADDR && inport_arvalid_i && inport_arready_o)
            read_port_q <= read_port_r;

        assign outport_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd0);
        assign outport_araddr_o  = inport_araddr_i;
        assign outport_rready_o  = inport_rready_i;

        assign outport_peripheral0_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd1);
        assign outport_peripheral0_araddr_o  = inport_araddr_i;
        assign outport_peripheral0_rready_o  = inport_rready_i;

        // Read timeout detection
        if (read_pending_q > timeout_threshold_i)
            timeout_flag_o = 1'b1; // Set timeout flag if threshold exceeded
        else
            timeout_flag_o = 1'b0;
    end

    //-------------------------------------------------------------
    // Write Request
    //-------------------------------------------------------------
    reg awvalid_q;
    reg wvalid_q;

    wire wr_cmd_accepted_w  = (inport_awvalid_i && inport_awready_o) || awvalid_q;
    wire wr_data_accepted_w = (inport_wvalid_i  && inport_wready_o)  || wvalid_q;

    always @ (posedge clk_i )
    begin
        if (rst_i)
            awvalid_q <= 1'b0;
        else if (inport_awvalid_i && inport_awready_o && (!wr_data_accepted_w))
            awvalid_q <= 1'b1;
        else if (wr_data_accepted_w)
            awvalid_q <= 1'b0;

        // Write timeout detection
        if (inport_awvalid_q && inport_awready_o && (!wvalid_q))
            timeout_flag_o = 1'b1; // Set timeout flag if write command is valid but data is not ready
        else
            timeout_flag_o = 1'b0;

        // Write command accepted
        if (inport_awvalid_i && inport_awready_o)
            write_port_q <= write_port_r;

        assign outport_awvalid_o = inport_awvalid_i & ~awvalid_q & write_accept_w & (write_port_r == `ADDR_SEL_W'd0);
        assign outport_awaddr_o  = inport_awaddr_i;
        assign outport_wvalid_o  = inport_wvalid_i & ~wvalid_q & (inport_awvalid_i || awvalid_q) & (write_port_r == `ADDR_SEL_W'd0);
        assign outport_wdata_o   = inport_wdata_i;
        assign outport_wstrb_o   = inport_wstrb_i;
        assign outport_bready_o  = inport_bready_i;

        // Write timeout detection
        if (inport_awvalid_q && inport_awready_o && (!wvalid_q))
            timeout_flag_o = 1'b1; // Set timeout flag if write command is valid but data is not ready
        else
            timeout_flag_o = 1'b0;

        assign inport_wready_o  = write_accept_w & ~wvalid_q & inport_wready_r;
    end

    // Transaction Error Handling (simplified example)
    // This could be expanded to include retry logic, logging, or error handling mechanisms
    always @*
    begin
        if (timeout_flag_o)
            // Handle timeout, e.g., log error, retry transaction, or abort
            // Placeholder for error handling logic
            // For example: log_error("Transaction timeout detected");
        end
    end

    //-----------------------------------------------------------------
    // AXI: Write
    //-----------------------------------------------------------------
    reg [3:0]              write_pending_q;
    reg [3:0]              write_pending_r;
    reg [`ADDR_SEL_W-1:0]  write_port_q;
    reg [`ADDR_SEL_W-1:0]  write_port_r;

    always @*
    begin
        if (inport_awvalid_i & ~awvalid_q)
            write_port_r = `ADDR_SEL_W'b0;
            if ((inport_awaddr_i & `PERIPH0_MASK) == `PERIPH0_ADDR) write_port_r = `ADDR_SEL_W'd1;
        else
            write_port_r = write_port_q;
    end

    wire write_incr_w;
    wire write_decr_w;

    always @ (posedge clk_i )
    begin
        if (rst_i)
            write_pending_q <= 4'b0;
        else
            write_pending_q <= write_pending_r;

        // Write command accepted
        if (inport_awvalid_i && inport_awready_o)
            write_port_q <= write_port_r;

        assign outport_awvalid_o = inport_awvalid_i & ~awvalid_q & write_accept_w & (write_port_r == `ADDR_SEL_W'd0);
        assign outport_awaddr_o  = inport_awaddr_i;
        assign outport_wvalid_o  = inport_wvalid_i & ~wvalid_q & (inport_awvalid_i || awvalid_q) & (write_port_r == `ADDR_SEL_W'd0);
        assign outport_wdata_o   = inport_wdata_i;
        assign outport_wstrb_o   = inport_wstrb_i;
        assign outport_bready_o  = inport_bready_i;

        // Write timeout detection
        if (inport_awvalid_i && inport_awready_o && (!wvalid_q))
            timeout_flag_o = 1'b1; // Set timeout flag if write command is valid but data is not ready
        else
            timeout_flag_o = 1'b0;

        assign inport_wready_o  = write_accept_w & ~wvalid_q & inport_wready_r;
    end

endmodule
