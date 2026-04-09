module axi_tap #(
    parameter ADDR_WIDTH = 32, // Width of AXI4-Lite Address
    parameter DATA_WIDTH = 32, // Width of AXI4-Lite Data
    parameter TIMEOUT_THRESHOLD = 1000 // Timeout threshold in cycles
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
    output [1:0]    inport_bresp_o,
    input           outport_awready_i,
    output          outport_awvalid_o,
    output [ADDR_WIDTH-1:0]   outport_awaddr_o,
    input           outport_wready_i,
    output          outport_wvalid_o,
    output [DATA_WIDTH-1:0]   outport_wdata_o,
    output [3:0]    outport_wstrb_o,
    input           outport_bvalid_i,
    output          outport_bresp_o,
    input           outport_arready_i,
    output          outport_arvalid_o,
    output [ADDR_WIDTH-1:0]   outport_araddr_o,
    input           outport_rvalid_i,
    input  [DATA_WIDTH-1:0]   outport_rdata_o,
    input  [1:0]    outport_rresp_o,
    output          outport_rready_o,

    // Timeout Handling Ports
    input           [TIMEOUT_THRESHOLD-1:0]  timeout_counter,
    output          timeout_flag,

    // Peripheral 0 interface
    // Write Address Channel (AW)
    input           outport_peripheral0_awready_i,
    output          outport_peripheral0_awvalid_o,
    output [ADDR_WIDTH-1:0]   outport_peripheral0_awaddr_o,
    input           outport_peripheral0_wready_i,
    output          outport_peripheral0_wvalid_o,
    output [DATA_WIDTH-1:0]   outport_peripheral0_wdata_o,
    output [3:0]    outport_peripheral0_wstrb_o,
    input           outport_peripheral0_bvalid_i,
    output          outport_peripheral0_bready_o,
    input           outport_arready_i,
    output          outport_arvalid_o,
    output [ADDR_WIDTH-1:0]   outport_araddr_o,
    input           outport_rvalid_i,
    input  [DATA_WIDTH-1:0]   outport_rdata_o,
    input  [1:0]    outport_rresp_i,
    output          outport_rready_o,

    // Timeout Control Logic
    reg timeout_counter_reg;
    reg timeout_flag_reg;

    // Transaction Start Logic
    always @(posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            timeout_counter_reg <= 0;
            timeout_flag_reg <= 0;
        end else if (inport_awvalid_i && inport_awready_o) begin
            timeout_counter_reg <= timeout_counter_reg + 1;
        end
    end

    // Timeout Detection Logic
    always @(posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            timeout_flag_reg <= 0;
        end else if (timeout_counter_reg >= TIMEOUT_THRESHOLD) begin
            timeout_flag_reg <= 1;
            timeout_counter_reg <= 0;
        end else if (outport_arvalid_o && outport_arready_o) begin
            timeout_counter_reg <= 0;
        end
    end

    // Transaction Completion Logic
    always @(posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            timeout_flag_reg <= 0;
        end else if (outport_arvalid_o && outport_rready_o) begin
            timeout_counter_reg <= timeout_counter_reg;
        end
    end

    // Transaction Error Handling Logic
    // This can be expanded based on specific error handling requirements
    // For example, retry mechanism or transaction abort
    // Here is a simple error handling that sets the timeout flag and resets the transaction
    assign timeout_flag_o = timeout_flag_reg;

    // Rest of the original axi_tap module code...

    `define ADDR_SEL_W           1
    `define PERIPH0_ADDR         32'h80000000
    `define PERIPH0_MASK         32'h80000000

    //-----------------------------------------------------------------
    // AXI: Read
    //-----------------------------------------------------------------
    reg [3:0]              read_pending_q;
    reg [3:0]              read_pending_r;
    reg [`ADDR_SEL_W-1:0]  read_port_q;
    reg [`ADDR_SEL_W-1:0]  read_port_r;

    always @*
    begin
        read_port_r = `ADDR_SEL_W'b0;
        if ((inport_araddr_i & `PERIPH0_MASK) == `PERIPH0_ADDR) read_port_r = `ADDR_SEL_W'd1;
    end

    wire read_incr_w = (inport_arvalid_i && inport_arready_o);
    wire read_decr_w = (inport_rvalid_o && inport_rready_i);

    always @*
    begin
        read_pending_r = read_pending_q;

        if (read_incr_w && !read_decr_w)
            read_pending_r = read_pending_r + 4'd1;
        else if (!read_incr_w && read_decr_w)
            read_pending_r = read_pending_r - 4'd1;
    end

    assign outport_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd0);
    assign outport_araddr_o  = inport_araddr_i;
    assign outport_rready_o  = inport_rready_i;

    assign outport_peripheral0_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd1);
    assign outport_peripheral0_araddr_o  = inport_araddr_i;
    assign outport_peripheral0_rready_o  = inport_rready_i;

    reg outport_rvalid_r;
    reg [DATA_WIDTH-1:0] outport_rdata_r;
    reg [1:0]  outport_rresp_r;

    always @*
    begin
        case (read_port_q)
        `ADDR_SEL_W'd1:
            outport_rvalid_r = outport_peripheral0_rvalid_i;
            outport_rdata_r  = outport_peripheral0_rdata_i;
            outport_rresp_r  = outport_peripheral0_rresp_i;
        default:
            outport_rvalid_r = outport_rvalid_i;
            outport_rdata_r  = outport_rdata_i;
            outport_rresp_r  = outport_rresp_i;
        endcase
    end

    assign inport_rvalid_o  = outport_rvalid_r;
    assign inport_rdata_o   = outport_rdata_r;
    assign inport_rresp_o   = outport_rresp_r;

    reg inport_arready_r;
    always @*
    begin
        case (read_port_r)
        `ADDR_SEL_W'd1:
            inport_arready_r = outport_peripheral0_arready_i;
        default:
            inport_arready_r = outport_arready_i;
        endcase
    end

    assign inport_arready_o = read_accept_w & inport_arready_r;

    //-------------------------------------------------------------
    // Write Request
    //-------------------------------------------------------------
    reg awvalid_q;
    reg wvalid_q;

    wire wr_cmd_accepted_w  = (inport_awvalid_i && inport_awready_o) || awvalid_q;
    wire wr_data_accepted_w = (inport_wvalid_i  && inport_wready_o)  || wvalid_q;

    always @(posedge clk_i or negedge rst_i) begin
        if (rst_i) begin
            awvalid_q <= 1'b0;
            wvalid_q <= 1'b0;
        end else if (inport_awvalid_i && inport_awready_o && (!wr_data_accepted_w)) begin
            awvalid_q <= 1'b1;
        end else if (wr_data_accepted_w) begin
            awvalid_q <= 1'b0;
        end

        if (inport_wvalid_i && inport_wready_o && (!wr_cmd_accepted_w)) begin
            wvalid_q <= 1'b1;
        end else if (wr_cmd_accepted_w) begin
            wvalid_q <= 1'b0;
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
        begin
            write_port_r = `ADDR_SEL_W'b0;
            if ((inport_awaddr_i & `PERIPH0_MASK) == `PERIPH0_ADDR) write_port_r = `ADDR_SEL_W'd1;
        end
        else
            write_port_r = write_port_q;
    end

    wire write_incr_w = (inport_awvalid_i && inport_awready_o);
    wire write_decr_w = (inport_bvalid_o  && inport_bready_i);

    always @*
    begin
        write_pending_r = write_pending_q;

        if (write_incr_w && !write_decr_w)
            write_pending_r = write_pending_r + 4'd1;
        else if (!write_incr_w && write_decr_w)
            write_pending_r = write_pending_r - 4'd1;
    end

    always @(posedge clk_i or negedge rst_i) begin
        if (rst_i) begin
            write_pending_q <= 4'b0;
            write_port_q    <= `ADDR_SEL_W'b0;
        end
        else begin
            write_pending_q <= write_pending_r;

            // Write command accepted
            if (inport_awvalid_i && inport_awready_o)
            begin
                write_port_q <= write_port_r;
            end
        end
    end

    wire write_accept_w      = (write_port_q == write_port_r && write_pending_q != 4'hF) || (write_pending_q == 4'h0);

    assign outport_awvalid_o = inport_awvalid_i & ~awvalid_q & write_accept_w & (write_port_r == `ADDR_SEL_W'd0);
    assign outport_awaddr_o  = inport_awaddr_i;
    assign outport_wvalid_o  = inport_wvalid_i & ~wvalid_q & (inport_awvalid_i || awvalid_q) & (write_port_r == `ADDR_SEL_W'd0);
    assign outport_wdata_o   = inport_wdata_i;
    assign outport_wstrb_o   = inport_wstrb_i;
    assign outport_bready_o  = inport_bready_i;

    assign outport_peripheral0_awvalid_o = inport_awvalid_i & ~awvalid_q & write_accept_w & (write_port_r == `ADDR_SEL_W'd1);
    assign outport_peripheral0_awaddr_o  = inport_awaddr_i;
    assign outport_peripheral0_wvalid_o  = inport_wvalid_i & ~wvalid_q & ((inport_awvalid_i && write_accept_w) || awvalid_q) & (write_port_r == `ADDR_SEL_W'd1);
    assign outport_peripheral0_wdata_o   = inport_wdata_i;
    assign outport_peripheral0_wstrb_o   = inport_wstrb_i;
    assign outport_peripheral0_bready_o  = inport_bready_i;

    reg outport_bvalid_r;
    reg [1:0]  outport_bresp_r;

    always @*
    begin
        case (write_port_q)
        `ADDR_SEL_W'd1:
            outport_bvalid_r = outport_peripheral0_bvalid_i;
            outport_bresp_r  = outport_peripheral0_bresp_i;
        default:
            outport_bvalid_r = outport_bvalid_i;
            outport_bresp_r  = outport_bresp_i;
        endcase
    end

    assign inport_bvalid_o  = outport_bvalid_r;
    assign inport_bresp_o   = outport_bresp_r;

    reg inport_awready_r;
    reg inport_wready_r;

    always @*
    begin
        case (write_port_r)
        `ADDR_SEL_W'd1:
            inport_awready_r = outport_peripheral0_awready_i;
            inport_wready_r  = outport_peripheral0_wready_i;
        default:
            inport_awready_r = outport_awready_i;
            inport_wready_r  = outport_wready_i;
        endcase
    end

    assign inport_awready_o = write_accept_w & ~awvalid_q & inport_awready_r;
    assign inport_wready_o  = write_accept_w & ~wvalid_q & inport_wready_r;

    // Timeout Handling for Reads
    assign timeout_flag_o = (inport_arvalid_i && ~inport_arready_r) & timeout_counter_reg >= TIMEOUT_THRESHOLD;

    // Timeout Handling for Writes
    assign timeout_flag_o = (inport_awvalid_i && ~inport_awready_r) & timeout_counter_reg >= TIMEOUT_THRESHOLD;

    // Rest of the original axi_tap module code...

endmodule
