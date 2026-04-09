module axi_tap #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input           clk_i,
    input           rst_i,
    input           inport_awvalid_i,
    input  [ADDR_WIDTH-1:0]   inport_awaddr_i,
    input           inport_awready_o,
    input           inport_wvalid_i,
    input  [DATA_WIDTH-1:0]   inport_wdata_i,
    input  [3:0]    inport_wstrb_i,
    input           inport_wready_o,
    input           inport_bready_i,
    input           inport_bvalid_i,
    output          inport_bresp_o,
    output          inport_rvalid_o,
    output  [DATA_WIDTH-1:0]   inport_rdata_o,
    output [1:0]    inport_rresp_o,
    output          inport_awready_r,
    output          inport_wready_r,
    output  [ADDR_WIDTH-1:0]   outport_awaddr_o,
    output          outport_awvalid_o,
    output  [DATA_WIDTH-1:0]   outport awdata_o,
    output [3:0]    outport awstrb_o,
    output          outport_wready_o,
    output          outport_bvalid_i,
    output  [1:0]    outport_bresp_i,
    output          outport_bready_o,
    output  [ADDR_WIDTH-1:0]   outport_araddr_o,
    output          outport_arvalid_o,
    output  [DATA_WIDTH-1:0]   outport ardata_o,
    output [1:0]    outport_arresp_o,
    output          outport_rready_o,
    output  [ADDR_WIDTH-1:0]   outport_peripheral0_awaddr_o,
    output          outport_peripheral0_awvalid_o,
    output  [DATA_WIDTH-1:0]   outport_peripheral0 awdata_o,
    output [3:0]    outport_peripheral0 awstrb_o,
    output          outport_peripheral0_wready_o,
    output          outport_peripheral0_wvalid_o,
    output  [DATA_WIDTH-1:0]   outport_peripheral0_wdata_o,
    output [3:0]    outport_peripheral0_wstrb_o,
    output          outport_peripheral0_bvalid_o,
    output  [1:0]    outport_peripheral0_bresp_o,
    output          outport_peripheral0_bready_o,
    output  [ADDR_WIDTH-1:0]   outport_peripheral0_araddr_o,
    output          outport_peripheral0_arvalid_o,
    output  [DATA_WIDTH-1:0]   outport_peripheral0 ardata_o,
    output [1:0]    outport_peripheral0 arresp_o,
    output          outport_peripheral0_rready_o
);

`define ADDR_ELSE 0
`define PERIPH0_ADDR 32'h80000000
`define PERIPH0_MASK 32'h80000000

// AXI: Read
reg [3:0]              read_pending_q;
reg [3:0]              read_pending_r;
reg [`ADDR_ELSE-1:0]  read_port_q;
reg [`ADDR_ELSE-1:0]  read_port_r;

always @ *
if (rst_i)
    read_pending_q <= 4'b0;
    read_port_q    <= `ADDR_ELSE'b0;
else
    read_pending_q <= read_pending_r;
    if (inport_arvalid_i && inport_arready_o)
        read_port_q <= read_port_r;

wire read_accept_w       = (read_port_q == read_port_r && read_pending_q != 4'hF) || (read_pending_q == 4'h0);

assign outport_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_ELSE'd0);
assign outport_araddr_o  = inport_araddr_i;
assign outport_rready_o  = inport_rready_i;

assign outport_peripheral0_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_ELSE'd1);
assign outport_peripheral0_araddr_o  = inport_araddr_i;
assign outport_peripheral0_rready_o  = inport_rready_i;

// AXI: Write
reg [3:0]              write_pending_q;
reg [3:0]              write_pending_r;
reg [`ADDR_ELSE-1:0]  write_port_q;
reg [`ADDR_ELSE-1:0]  write_port_r;

always @ (posedge clk_i)
if (rst_i)
    write_pending_q <= 4'b0;
    write_port_q    <= `ADDR_ELSE'b0;
else
    write_pending_q <= write_pending_r;
    if (inport_awvalid_i && inport_awready_o && (!wr_data_accepted_w))
        write_pending_q <= 1'b1;
    else if (wr_data_accepted_w)
        write_pending_q <= 4'b0;

always @ (posedge clk_i)
if (rst_i)
    wvalid_q <= 1'b0;
else if (inport_wvalid_i && inport_wready_o && !wr_cmd_accepted_w)
    wvalid_q <= 1'b1;
else if (wr_cmd_accepted_w)
    wvalid_q <= 4'b0;

wire wr_cmd_accepted_w  = (inport_awvalid_i && inport_awready_o) || wvalid_q;
wire wr_data_accepted_w = (inport_wvalid_i  && inport_wready_o)  || wvalid_q;

wire write_accept_w      = (write_port_q == write_port_r && write_pending_q != 4'hF) || (write_pending_q == 4'h0);

assign outport_awvalid_o = inport_awvalid_i & ~awvalid_q & write_accept_w & (write_port_r == `ADDR_ELSE'd0);
assign outport_awaddr_o  = inport_awaddr_i;
assign outport_wvalid_o  = inport_wvalid_i & ~wvalid_q & (inport_awvalid_i || awvalid_q) & (write_port_r == `ADDR_ELSE'd0);
assign outport_wdata_o   = inport_wdata_i;
assign outport_wstrb_o   = inport_wstrb_i;
assign outport_bready_o  = inport_bready_i;

assign outport_peripheral0_awvalid_o = inport_awvalid_i & ~awvalid_q & write_accept_w & (write_port_r == `ADDR_ELSE'd1);
assign outport_peripheral0_awaddr_o  = inport_awaddr_i;
assign outport_peripheral0_wvalid_o  = inport_wvalid_i & ~wvalid_q & ((inport_awvalid_i && write_accept_w) || awvalid_q) & (write_port_r == `ADDR_ELSE'd1);
assign outport_peripheral0_wdata_o   = inport_wdata_i;
assign outport_peripheral0_wstrb_o   = inport_wstrb_i;
assign outport_peripheral0_bready_o  = inport_bready_i;

reg outport_bvalid_r;
reg [1:0]  outport_bresp_r;

always @ *
begin
    case (write_port_q)
        `ADDR_ELSE'd1:
        begin
            outport_bvalid_r = outport_peripheral0_bvalid_i;
            outport_bresp_r  = outport_peripheral0_bresp_i;
        end
        default:
        begin
            outport_bvalid_r = outport_bvalid_i;
            outport_bresp_r  = outport_bresp_i;
        end
    endcase
end

assign inport_bvalid_o  = outport_bvalid_r;
assign inport_bresp_o   = outport_bresp_r;

reg inport_awready_r;
reg inport_wready_r;

always @ *
begin
    case (write_port_r)
        `ADDR_ELSE'd1:
        begin
            inport_awready_r = outport_peripheral0_awready_i;
            inport_wready_r  = outport_peripheral0_wready_i;
        end
        default:
        begin
            inport_awready_r = outport_awready_i;
            inport_wready_r  = outport_wready_i;
        end
    endcase
end

assign inport_awready_o = write_accept_w & ~awvalid_q & inport_awready_r;
assign inport_wready_o  = write_accept_w & ~wvalid_q & inport_wready_r;

endmodule