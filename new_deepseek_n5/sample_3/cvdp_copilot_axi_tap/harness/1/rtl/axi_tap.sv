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
    input          inport_bvalid_i,
    output          inport_bresp_o,
    output [1:0]    inport_rresp_o,
    output          inport_arvalid_o,
    output          inport_arready_o,
    output  [ADDR_WIDTH-1:0]   inport_araddr_o,
    output          inport_rvalid_o,
    output  [DATA_WIDTH-1:0]   inport_rdata_o,
    output [1:0]    inport_rresp_o,
    output          outport_awready_i,
    output          outport_awvalid_o,
    output  [ADDR_WIDTH-1:0]   outport_awaddr_o,
    output          outport_wvalid_o,
    output  [DATA_WIDTH-1:0]   outport_wdata_o,
    output  [3:0]    outport_wstrb_o,
    output          outport_wready_o,
    output          outport_bvalid_i,
    output [1:0]    outport_bresp_i,
    output          outport_bready_o,
    output  [ADDR_WIDTH-1:0]   outport_araddr_o,
    output          outport_rvalid_o,
    output  [DATA_WIDTH-1:0]   outport_rdata_o,
    output [1:0]    outport_rresp_o,
    output          outport_rready_o,

    // Default AXI outport
    // Write Address Channel (AW)
    input           outport_awready_i,
    output          outport_awvalid_o,
    output  [ADDR_WIDTH-1:0]   outport_awaddr_o,
    // Write Data Channel (W)
    input           outport_wready_i,
    output          outport_wvalid_o,
    output  [DATA_WIDTH-1:0]   outport_wdata_o,
    output  [3:0]    outport_wstrb_o,
    // Write Response Channel (B)
    input  [1:0]    outport_wresp_i,
    input           outport_wresp_o,
    output          outport_wvalid_o,
    // Read Address Channel (AR)
    input           outport_arready_i,
    output          outport_arvalid_o,
    output  [ADDR_WIDTH-1:0]   outport_araddr_o,
    // Read Data Channel (R)
    input  [1:0]    outport_rresp_i,
    input           outport_rresp_o,
    output          outport_rvalid_o,
    output  [DATA_WIDTH-1:0]   outport_rdata_o,

    //Peripheral 0 interface
    // Write Address Channel (AW)
    input           outport_peripheral0_awready_i,
    output          outport_peripheral0_awvalid_o,
    output  [ADDR_WIDTH-1:0]   outport_peripheral0_awaddr_o,
    // Write Data Channel (W)
    input           outport_peripheral0_wready_i,
    output          outport_peripheral0_wvalid_o,
    output  [DATA_WIDTH-1:0]   outport_peripheral0_wdata_o,
    output  [3:0]    outport_peripheral0_wstrb_o,
    // Write Response Channel (B)
    input  [1:0]    outport_peripheral0_bresp_i,
    input           outport_peripheral0_bvalid_i,
    output          outport_peripheral0_bready_o,
    // Read Address Channel (AR)
    input           outport_peripheral0_arready_i,
    output          outport_peripheral0_arvalid_o,
    output  [ADDR_WIDTH-1:0]   outport_peripheral0_araddr_o,
    // Read Data Channel (R)
    input  [1:0]    outport_peripheral0_rresp_i,
    input           outport_peripheral0_rvalid_i,
    input  [DATA_WIDTH-1:0]   outport_peripheral0_rdata_i,
    output          outport_peripheral0_rready_o
);

`define ADDR_ELSE 0
`define PERIPH0_ADDR 0x80000000
`define PERIPH0_MASK 0x80000000

// Read Port
reg [3:0]       read_pending_q;
reg [3:0]       read_pending_r;
reg [`ADDR_ELSE-1:0] read_port_q;
reg [`ADDR_ELSE-1:0] read_port_r;

wire read_accept_w       = (read_port_q == read_port_r && read_pending_q != 4'hF) || (read_pending_q == 4'h0);

always @ (posedge clk_i)
if (rst_i)
begin
    read_pending_q <= 4'h0;
    read_port_q    <= `ADDR_ELSE'b0;
end
else
begin
    read_pending_q <= read_pending_r;
    if (inport_arvalid_i && inport_arready_o)
    begin
        read_port_q <= read_port_r;
    end
end

wire read_accept_w       = (read_port_q == read_port_r && read_pending_q != 4'hF) || (read_pending_q == 4'h0);

assign outport_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_ELSE'd0);
assign outport_araddr_o  = inport_araddr_i;
assign outport_rready_o  = inport_rready_i;

assign outport_peripheral0_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_ELSE'd1);
assign outport_peripheral0_araddr_o  = inport_araddr_i;
assign outport_peripheral0_rready_o  = inport_rready_i;

// Write Port
reg [3:0]       write_pending_q;
reg [3:0]       write_pending_r;
reg [`ADDR_ELSE-1:0] write_port_q;
reg [`ADDR_ELSE-1:0] write_port_r;

wire write_accept_w      = (write_port_q == write_port_r && write_pending_q != 4'hF) || (write_pending_q == 4'h0);

always @ (posedge clk_i)
if (rst_i)
begin
    write_pending_q <= 4'h0;
    write_port_q    <= `ADDR_ELSE'b0;
end
else
begin
    write_pending_q <= write_pending_r;
    if (inport_awvalid_i && inport_awready_o && !write_accept_w)
    begin
        write_pending_q <= 4'hF;
        write_port_q <= `ADDR_ELSE'b0;
    end
end

wire write_accept_w      = (write_port_q == write_port_r && write_pending_q != 4'hF) || (write_pending_q == 4'h0);

always @ (posedge clk_i)
if (rst_i)
begin
    inport_awready_r = 4'h0;
    inport_wready_r  = 4'h0;
end
else
begin
    inport_awready_r = write_port_r;
    inport_wready_r  = write_port_r;
end

assign inport_awready_o = write_accept_w & ~write_pending_q & inport_awready_r;
assign inport_wready_o  = write_accept_w & ~write_pending_q & inport_wready_r;

// peripheral0 write
wire [3:0] peripheral0_mask = `0x80000000;
wire [3:0] peripheral0_addr_valid = inport_arvalid_i;
wire [3:0] peripheral0_addr_valid peripheral0_addr_valid_o;

wire [3:0] peripheral0_data_valid = inport_wvalid_i;
wire [3:0] peripheral0_data_valid peripheral0_data_valid_o;

wire [3:0] peripheral0_data peripheral0_data_o;

wire [3:0] peripheral0_response_valid = inport_bvalid_i;
wire [3:0] peripheral0_response_valid peripheral0_response_valid_o;

wire [3:0] peripheral0_response peripheral0_response_o;

// peripheral0 read
wire [3:0] peripheral0_addr_valid = outport_arvalid_o;
wire [3:0] peripheral0_addr_valid peripheral0_addr_valid_i;

wire [3:0] peripheral0_data_valid = outport_rvalid_o;
wire [3:0] peripheral0_data_valid peripheral0_data_valid_i;

wire [3:0] peripheral0_data = outport_rdata_o;
wire [3:0] peripheral0_data peripheral0_data_i;

wire [3:0] peripheral0_response_valid = outport_bvalid_o;
wire [3:0] peripheral0_response_valid peripheral0_response_valid_i;

wire [3:0] peripheral0_response = outport_bresp_o;
wire [3:0] peripheral0_response peripheral0_response_i;

// Default write
wire [3:0] default_mask = 0x00000000;
wire [3:0] default_addr_valid = inport_arvalid_i;
wire [3:0] default_addr_valid default_addr_valid_o;

wire [3:0] default_data_valid = inport_wvalid_i;
wire [3:0] default_data_valid default_data_valid_o;

wire [3:0] default_data default_data_o;

wire [3:0] default_response_valid = inport_bvalid_i;
wire [3:0] default_response_valid default_response_valid_o;

wire [3:0] default_response default_response_o;

// Default read
wire [3:0] default_addr_valid = outport_arvalid_o;
wire [3:0] default_addr_valid default_addr_valid_i;

wire [3:0] default_data_valid = outport_rvalid_o;
wire [3:0] default_data_valid default_data_valid_i;

wire [3:0] default_data = outport_rdata_o;
wire [3:0] default_data default_data_i;

wire [3:0] default_response_valid = outport_bvalid_o;
wire [3:0] default_response_valid default_response_valid_i;

wire [3:0] default_response = outport_bresp_o;
wire [3:0] default_response default_response_i;

wire [3:0] default_response_valid = outport_bvalid_o;
wire [3:0] default_response_valid default_response_valid_i;

wire [3:0] default_response = outport_bresp_o;
wire [3:0] default_response default_response_i;

wire [3:0] default_response_valid = outport_bvalid_o;
wire [3:0] default_response_valid default_response_valid_i;

wire [3:0] default_response = outport_bresp_o;
wire [3:0] default_response default_response_i;