// rtl/axi_tap.sv
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
    // Read Address Channel (AR)
    input           outport_arready_i,
    output          outport_arvalid_o,
    output [ADDR_WIDTH-1:0]   outport_araddr_o,
    // Read Data Channel (R)
    input           outport_rvalid_i,
    input  [DATA_WIDTH-1:0]   outport_rdata_i,
    input  [1:0]    outport_rresp_i,
    output          outport_rready_o,

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
    input  [1:0]    outport_peripheral0_rresp_i,
    input           outport_peripheral0_rvalid_i,
    output          outport_peripheral0_rdata_o
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
    read_pending_r <= read_pending_q;

    // Read command accepted
    if (inport_arvalid_i && inport_arready_o)
    begin
        read_port_r <= read_port_q;
    end
end

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
    awvalid_q <= 1'b0;
    if (rst_i)
        awvalid_q <= 1'b0;
    else if (inport_awvalid_i && inport_awready_o && (!wr_data_accepted_w))
        awvalid_q <= 1'b1;
    else if (wr_data_accepted_w)
        awvalid_q <= 1'b0;

    wvalid_q <= 1'b0;
    if (rst_i)
        wvalid_q <= 1'b0;
    else if (inport_wvalid_i && inport_wready_o && !wr_cmd_accepted_w)
        wvalid_q <= 1'b1;

//-----------------------------------------------------------------
// AXI: Write
//-----------------------------------------------------------------

// Write Request Logic
always @ (posedge clk_i )
begin
    // Determine the write port based on address matching
    case ({inport_awaddr_i & PERIPH0_MASK})
        `PERIPH0_ADDR': read_port_q = read_port_r = `ADDR_SEL_W'd1;
        default:          read_port_q = read_port_r = `ADDR_SEL_W'd0;
    endcase

    // Handle backpressure for write requests
    if (awvalid_q && (read_pending_q == 4'hF || write_port_r == `ADDR_SEL_W'd1))
        inport_awready_o <= 1'b0; // Prevent accepting new AW if write is pending

    // Handle backpressure for write data
    if (wvalid_q && (read_pending_r == 4'hF || write_port_r == `ADDR_SEL_W'd1))
        inport_wready_o <= 1'b0; // Prevent accepting new W if write is pending
end

//-----------------------------------------------------------------
// AXI: Write Response
//-----------------------------------------------------------------

// Write Response Logic
always @ (posedge clk_i )
begin
    // Determine the write port based on address matching
    case ({inport_bresp_i, inport_bvalid_i})
        `PERIPH0_ADDR' && 1'b1: begin
            outport_peripheral0_awvalid_o <= 1'b1;
            outport_peripheral0_awaddr_o <= inport_araddr_o;
            outport_peripheral0_wready_o <= 1'b1;
            outport_peripheral0_wvalid_o <= inport_wvalid_i;
            outport_peripheral0_wdata_o <= inport_wdata_i;
            outport_peripheral0_wstrb_o <= inport_wstrb_i;
            outport_peripheral0_bvalid_i <= 1'b1;
            outport_peripheral0_bresp_i <= `PERIPH0_MASK;
        end
        default: begin
            outport_awvalid_o <= 1'b0;
            outport_awaddr_o <= `ADDR_SEL_W'b0;
            outport_wready_o <= 1'b0;
            outport_wvalid_o <= 1'b0;
            outport_wdata_o <= `ADDR_SEL_W'b0;
            outport_wstrb_o <= `ADDR_SEL_W'b0;
            outport_bvalid_o <= inport_bvalid_i;
            outport_bresp_o <= inport_bresp_i;
            outport_bready_o <= inport_bready_i;
        end
end

// Forward write response to correct interface
assign inport_bvalid_o  = outport_bvalid_r;
assign inport_bresp_o   = outport_bresp_r;

reg inport_awready_r;
reg inport_wready_r;

always @ (posedge clk_i )
begin
    case (write_port_r)
    `ADDR_SEL_W'd1:
    begin
        inport_awready_r = outport_peripheral0_awready_i;
        inport_wready_r  = outport_peripheral0_wready_i;
    end
    default:
    begin
        inport_awready_r = outport_awready_i;
        inport_wready_r  = outport_wready_i;
    end
end

assign inport_awready_o = write_accept_w & ~awvalid_q & inport_awready_r;
assign inport_wready_o  = write_accept_w & ~wvalid_q & inport_wready_r;

endmodule
