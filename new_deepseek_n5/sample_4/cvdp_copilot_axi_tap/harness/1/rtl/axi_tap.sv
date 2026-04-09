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
    output          inport_wready_o,
    input           inport_bready_i,
    output          inport_bvalid_o,
    output [1:0]    inport_bresp_o,
    input           inport_arvalid_i,
    input  [ADDR_WIDTH-1:0]   inport_araddr_i,
    output          inport_arready_o,
    input           inport_rready_i,
    output          inport_rvalid_o,
    output [DATA_WIDTH-1:0]   inport_rdata_o,
    output [1:0]    inport_rresp_o,
    output          outport_awready_i,
    output          outport_awvalid_o,
    output  [ADDR_WIDTH-1:0]   outport_awaddr_o,
    output          outport_wready_i,
    output          outport_wvalid_o,
    output  [DATA_WIDTH-1:0]   outport_wdata_o,
    output  [3:0]    outport_wstrb_o,
    output          outport_bvalid_i,
    input           outport_bready_o,
    output          outport_bresp_i,
    output [1:0]    outport_bresp_o,
    input           outport_arready_i,
    output          outport_arvalid_o,
    output  [ADDR_WIDTH-1:0]   outport_araddr_o,
    output          outport_rready_i,
    output          outport_rvalid_o,
    output  [DATA_WIDTH-1:0]   outport_rdata_i,
    output [1:0]    outport_rresp_i
);

// Address decoding logic
reg [3:0]    address_mask = 0x80000000;
reg [3:0]    peripheral_address = inport_awaddr_i & address_mask;

// Read FIFO
reg [ADDR_WIDTH-1:0]    read_pending_q;
reg [3:0]    read_port_q;

always @ (posedge clk_i) begin
    if (rst_i) begin
        read_pending_q = 0;
        read_port_q = 0;
    else
        read_port_q = read_pending_q;
        read_pending_q = inport_araddr_i & address_mask;
    end
end

// Read logic
reg [3:0]    read_accept_w;
wire read_port_r = inport_araddr_i & address_mask;

always @ (posedge clk_i) begin
    if (rst_i) begin
        read_port_r = 0;
    end else if (inport_arvalid_i & inport_arready_o) begin
        read_port_r = read_port_q;
    end else if (read_port_q == 0) begin
        read_port_r = 0;
    end
end

always @ (posedge clk_i) begin
    if (rst_i) begin
        read_accept_w = 0;
    else if (inport_arvalid_i & inport_arready_o) begin
        read_accept_w = 1;
    else if (read_port_q == 0) begin
        read_accept_w = 0;
    end
end

// Write FIFO
reg [3:0]    write_port_q;
reg [ADDR_WIDTH-1:0]    write_port_r;

always @ (posedge clk_i) begin
    if (rst_i) begin
        write_port_q = 0;
        write_port_r = 0;
    else
        write_port_q = write_port_r;
        write_port_r = inport_awaddr_i & address_mask;
    end
end

// Write logic
wire write_accept_w = (write_port_q == write_port_r) | (write_port_r == 0);

always @ (posedge clk_i) begin
    if (rst_i) begin
        write_accept_w = 0;
    end else if (inport_awvalid_i & inport_awready_o) begin
        write_accept_w = 1;
    end else if (write_port_q == 0) begin
        write_accept_w = 0;
    end
end

//Peripheral 0 interface
wire outport_peripheral0_awvalid_o = inport_awvalid_i & ~awvalid_q & write_accept_w & (write_port_r == 0);
wire outport_peripheral0_awaddr_o = inport_awaddr_i;
wire outport_peripheral0_wvalid_o = inport_wvalid_i & ~wvalid_q & (inport_awvalid_i | awvalid_q) & (write_port_r == 0);
wire outport_peripheral0_wdata_o = inport_wdata_i;
wire outport_peripheral0_wstrb_o = inport_wstrb_i;
wire outport_peripheral0_bvalid_o = inport_bvalid_i;
wire outport_peripheral0_bresp_o = inport_bresp_i;

// Default interface
wire outport_default_awvalid_o = inport_awvalid_i & ~awvalid_q & write_accept_w & (write_port_r == 1);
wire outport_default_awaddr_o = inport_awaddr_i;
wire outport_default_wvalid_o = inport_wvalid_i & ~wvalid_q & (inport_awvalid_i | awvalid_q) & (write_port_r == 1);
wire outport_default_wdata_o = inport_wdata_i;
wire outport_default_wstrb_o = inport_wstrb_i;
wire outport_default_bvalid_o = inport_bvalid_i;
wire outport_default_bresp_o = inport_bresp_i;

// peripheral0 response
wire outport_peripheral0_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == 0);
wire outport_peripheral0_araddr_o = inport_araddr_i;
wire outport_peripheral0_rvalid_o = inport_rvalid_i;
wire outport_peripheral0_rdata_o = inport_rdata_i;
wire outport_peripheral0_rresp_o = inport_rresp_i;

// default response
wire outport_default_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == 1);
wire outport_default_araddr_o = inport_araddr_i;
wire outport_default_rvalid_o = inport_rvalid_i;
wire outport_default_rdata_o = inport_rdata_i;
wire outport_default_rresp_o = inport_rresp_i;

// peripheral0 write
wire outport_peripheral0_wvalid_o = inport_wvalid_i & ~wvalid_q & (inport_awvalid_i | awvalid_q) & (write_port_r == 0);
wire outport_peripheral0_wdata_o = inport_wdata_i;
wire outport_peripheral0_wstrb_o = inport_wstrb_i;

// default write
wire outport_default_wvalid_o = inport_wvalid_i & ~wvalid_q & (inport_awvalid_i | awvalid_q) & (write_port_r == 1);
wire outport_default_wdata_o = inport_wdata_i;
wire outport_default_wstrb_o = inport_wstrb_i;

// peripheral0 response
wire outport_peripheral0_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == 0);
wire outport_peripheral0_araddr_o = inport_araddr_i;
wire outport_peripheral0_rvalid_o = inport_rvalid_i;
wire outport_peripheral0_rdata_o = inport_rdata_i;
wire outport_peripheral0_rresp_o = inport_rresp_i;

// default response
wire outport_default_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == 1);
wire outport_default_araddr_o = inport_araddr_i;
wire outport_default_rvalid_o = inport_rvalid_i;
wire outport_default_rdata_o = inport_rdata_i;
wire outport_default_rresp_o = inport_rresp_i;

// peripheral0 response
wire outport_peripheral0_bvalid_o = inport_bvalid_i;
wire outport_peripheral0_bresp_o = inport_bresp_i;

// default response
wire outport_default_bvalid_o = inport_bvalid_i;
wire outport_default_bresp_o = inport_bresp_i;

endmodule