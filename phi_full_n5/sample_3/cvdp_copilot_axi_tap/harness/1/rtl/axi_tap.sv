module axi_tap #(
    parameter ADDR_WIDTH = 32, // Width of AXI4-Lite Address
    parameter DATA_WIDTH = 32  // Width of AXI4-Lite Data
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

    // Default AXI outport
    // Write Address Channel (AW)
    input           outport_awready_i,
    output          outport_awvalid_o,
    output [`ADDR_WIDTH-1:0]   outport_awaddr_o,
    // Write Data Channel (W)
    input           outport_wready_i,
    output          outport_wvalid_o,
    output [DATA_WIDTH-1:0]   outport_wdata_o,
    output [3:0]    outport_wstrb_o,
    // Write Response Channel (B)
    input           outport_bvalid_i,
    input  [1:0]    outport_bresp_i,
    output          outport_bready_o,
    // Read Address Channel (AR)
    input           outport_arready_i,
    output          outport_arvalid_o,
    output [`ADDR_WIDTH-1:0]   outport_araddr_o,
    // Read Data Channel (R)
    input           outport_rvalid_i,
    input  [DATA_WIDTH-1:0]   outport_rdata_i,
    input  [1:0]    outport_rresp_i,
    output          outport_rready_o,

    // Peripheral 0 interface
    // Write Address Channel (AW)
    input           outport_peripheral0_awready_i,
    output          outport_peripheral0_awvalid_o,
    output [`ADDR_WIDTH-1:0]   outport_peripheral0_awaddr_o,
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
    output [`ADDR_WIDTH-1:0]   outport_peripheral0_araddr_o,
    // Read Data Channel (R)
    input           outport_peripheral0_rready_o,
    input  [DATA_WIDTH-1:0]   outport_peripheral0_rdata_i
);

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

always @ *
begin
    read_pending_q <= 4'b0;
    read_port_q    <= `ADDR_SEL_W'b0;
end

always @ (*)
begin
    if (inport_arvalid_i && inport_arready_o)
    begin
        read_port_r <= read_port_q;
        read_pending_q <= read_pending_r;
    end
    else
    begin
        read_pending_q <= 4'bF;
    end
end

wire read_accept_w       = (read_port_q == read_port_r && read_pending_q != 4'hF) || (read_pending_q == 4'b0);

assign outport_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd0);
assign outport_araddr_o  = inport_araddr_i;
assign outport_rready_o  = inport_rready_i;

assign outport_peripheral0_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd1);
assign outport_peripheral0_araddr_o  = inport_araddr_i;
assign outport_peripheral0_rready_o  = inport_rready_i;

// Insert  AXI Read channel logic here

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
end

always @ (posedge clk_i )
begin
    if (rst_i)
        wvalid_q <= 1'b0;
    else if (inport_wvalid_i && inport_wready_o && (!wr_cmd_accepted_w))
        wvalid_q <= 1'b1;
    else if (wr_cmd_accepted_w)
        wvalid_q <= 1'b0;
end

//-----------------------------------------------------------------
// AXI: Write
//-----------------------------------------------------------------

// Write Address Channel (AW) logic
always @ (posedge clk_i)
begin
    if (rst_i)
        outport_awvalid_o <= 1'b0;
    else if (inport_awvalid_i && inport_awready_o)
    begin
        outport_awaddr_o <= inport_awaddr_i;
        if (addr_match(`PERIPH0_MASK))
            outport_peripheral0_awvalid_o <= 1'b1;
        else
            outport_awvalid_o <= 1'b0;
    end
    else
        outport_awvalid_o <= 1'b0;
end

// Write Data Channel (W) logic
always @ (posedge clk_i)
begin
    if (rst_i)
        outport_wvalid_o <= 1'b0;
    else if (inport_wvalid_i && inport_wready_o)
    begin
        outport_wdata_o <= inport_wdata_i;
        outport_wstrb_o <= inport_wstrb_i;
        if (addr_match(`PERIPH0_MASK))
            outport_peripheral0_wvalid_o <= 1'b1;
        else
            outport_wvalid_o <= 1'b0;
    end
end

// Write Response Channel (B) logic
always @ (posedge clk_i)
begin
    if (rst_i)
        outport_bvalid_r <= 1'b0;
    else if (inport_bvalid_i)
    begin
        outport_bvalid_r <= 1'b1;
        case (write_port_q)
        `ADDR_SEL_W'd1:
            outport_bresp_r  <= outport_peripheral0_bresp_i;
        default:
            outport_bresp_r  <= outport_bresp_i;
        endcase
    end
end

assign inport_bvalid_o  = outport_bvalid_r;
assign inport_bresp_o   = outport_bresp_r;

reg inport_awready_r;
reg inport_wready_r;

always @ (*)
begin
    case (write_port_r)
    `ADDR_SEL_W'd1:
        inport_awready_r <= outport_peripheral0_awready_i;
        inport_wready_r  <= outport_peripheral0_wready_i;
    default:
        inport_awready_r <= outport_awready_i;
        inport_wready_r  <= outport_wready_i;
    endcase
end

assign inport_awready_o = write_accept_w & ~awvalid_q & inport_awready_r;
assign inport_wready_o  = write_accept_w & ~wvalid_q & inport_wready_r;

endmodule
