module axi_tap #(
    parameter ADDR_WIDTH = 32, // Width of AXI4-Lite Address
    parameter DATA_WIDTH = 32, // Width of AXI4-Lite Data
    parameter TIMEOUT_THRESHOLD = 1000 // Timeout threshold in clock cycles
)(
    // Global Ports
    input           clk_i,
    input           rst_i,

    // Master Write Address Channel (AW)
    input           inport_awvalid_i,
    input  [ADDR_WIDTH-1:0]   inport_awaddr_i,
    output          inport_awready_o,
    input           inport_wvalid_i,
    input  [DATA_WIDTH-1:0]   inport_wdata_i,
    input  [3:0]    inport_wstrb_i,
    output          inport_wready_o,
    input           inport_bvalid_o,
    input  [1:0]    inport_bresp_o,
    output          inport_arvalid_o,
    output [ADDR_WIDTH-1:0]   inport_araddr_i,
    input           inport_rvalid_o,
    output [DATA_WIDTH-1:0]   inport_rdata_i,
    output  [1:0]    inport_rresp_o,
    input           outport_awready_i,
    output          outport_awvalid_o,
    output [ADDR_WIDTH-1:0]   outport_awaddr_o,
    input           outport_wready_i,
    output          outport_wvalid_o,
    output [DATA_WIDTH-1:0]   outport_wdata_o,
    output [3:0]    outport_wstrb_o,
    input           outport_bvalid_i,
    input  [1:0]    outport_bresp_i,
    output          outport_bready_o,
    input           outport_arready_i,
    output          outport_arvalid_o,
    output [ADDR_WIDTH-1:0]   outport_araddr_o,
    input           outport_rvalid_i,
    output          outport_rdata_o,
    output  [1:0]    outport_rresp_i,
    output          outport_rready_o,

    // Timeout Controls
    input           timeout_threshold_i,
    output          timeout_flag_o,

    // Peripheral 0 interface
    input           outport_peripheral0_awready_i,
    output          outport_peripheral0_awvalid_o,
    output [ADDR_WIDTH-1:0]   outport_peripheral0_awaddr_o,
    input           outport_peripheral0_wready_i,
    output          outport_peripheral0_wvalid_o,
    output [DATA_WIDTH-1:0]   outport_peripheral0_wdata_o,
    output [3:0]    outport_peripheral0_wstrb_o,
    input  [1:0]    outport_peripheral0_bresp_i,
    output          outport_peripheral0_bvalid_o,
    output          outport_peripheral0_bready_o,
    input           outport_peripheral0_arready_i,
    output          outport_peripheral0_arvalid_o,
    output [ADDR_WIDTH-1:0]   outport_peripheral0_araddr_o,
    input           outport_peripheral0_rready_o,
    input  [DATA_WIDTH-1:0]   outport_peripheral0_rdata_o,
    output          outport_peripheral0_rresp_o
);

    // Transaction Status Registers
    reg [3:0]              read_pending_q;
    reg [3:0]              write_pending_q;
    reg [`ADDR_SEL_W-1:0]  read_port_q;
    reg [`ADDR_SEL_W-1:0]  write_port_q;
    reg [`ADDR_SEL_W-1:0]  read_port_r;
    reg [`ADDR_SEL_W-1:0]  write_port_r;

    // Transaction Validity Registers
    reg awvalid_q;
    reg wvalid_q;

    // Timer Registers
    reg [TIMEOUT_THRESHOLD-1:0] timeout_counter_r;

    // Transaction Error Handling
    assign timeout_flag_o = (timeout_counter_r >= timeout_threshold_i);

    //-----------------------------------------------------------------
    // AXI: Read
    //-----------------------------------------------------------------
    always @ *
    begin
        if (inport_araddr_i & `PERIPH0_MASK == `PERIPH0_ADDR)
        begin
            read_port_r = `ADDR_SEL_W'd1;
            read_pending_r = read_pending_q;
            timeout_counter_r <= 0;
        end
        else
            read_port_r = write_port_r;

        if (inport_arvalid_i && inport_arready_o)
        begin
            read_port_q <= read_port_r;
            timeout_counter_r <= TIMEOUT_THRESHOLD;
        end
        else
            timeout_counter_r <= timeout_counter_r + 1;

        if (timeout_counter_r >= timeout_threshold_i)
            timeout_flag_o = 1;
    end

    always @ (posedge clk_i)
    begin
        if (rst_i)
        begin
            read_pending_q <= 4'b0;
            read_port_q    <= `ADDR_SEL_W'b0;
            timeout_counter_r <= 0;
        end
        else
        begin
            read_pending_q <= read_pending_r;
            read_port_q    <= read_port_q;
            timeout_counter_r <= timeout_counter_r;
        end
    end

    //-------------------------------------------------------------
    // Write Request
    //-------------------------------------------------------------
    reg awvalid_q;
    reg wvalid_q;

    always @ (posedge clk_i)
    begin
        if (inport_awvalid_i && inport_awready_o)
        begin
            awvalid_q <= 1'b1;
            timeout_counter_r <= TIMEOUT_THRESHOLD;
        end
        else if (awvalid_q && ~inport_awready_o)
            timeout_counter_r <= timeout_counter_r + 1;

        if (timeout_counter_r >= timeout_threshold_i)
            timeout_flag_o = 1;
    end

    always @ (posedge clk_i)
    begin
        if (inport_wvalid_i && inport_wready_o)
        begin
            wvalid_q <= 1'b1;
            timeout_counter_r <= TIMEOUT_THRESHOLD;
        end
        else if (wvalid_q && ~inport_wready_o)
            timeout_counter_r <= timeout_counter_r + 1;

        if (timeout_counter_r >= timeout_threshold_i)
            timeout_flag_o = 1;
    end

    //-----------------------------------------------------------------
    // AXI: Write
    //-----------------------------------------------------------------
    always @ (posedge clk_i)
    begin
        if (inport_awvalid_i & ~awvalid_q)
        begin
            write_port_r = `ADDR_SEL_W'b0;
            if ((inport_awaddr_i & `PERIPH0_MASK) == `PERIPH0_ADDR) write_port_r = `ADDR_SEL_W'd1;
        end
        else
            write_port_r = write_port_q;

        if (inport_wvalid_i && inport_wready_o)
        begin
            wvalid_q <= 1'b1;
            timeout_counter_r <= TIMEOUT_THRESHOLD;
        end
        else if (wvalid_q && ~inport_wready_o)
            timeout_counter_r <= timeout_counter_r + 1;

        if (timeout_counter_r >= timeout_threshold_i)
            timeout_flag_o = 1;
    end

    // Transaction Error Handling Logic
    // (This should be implemented in the higher-level logic that monitors timeout_flag_o)
    // Possible actions: retry transaction, log error, send alert, etc.

endmodule
