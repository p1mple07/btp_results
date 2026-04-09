module axi_tap #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter TIMEOUT_THRESHOLD = 1000
)(
    input           clk_i,
    input           rst_i,

    // New ports for timeout functionality
    input           timeout_timer,
    input           TIMEOUT_THRESHOLD,
    output          timeout_flag,
    // Default AXI4-Lite ports
    input           inport_awvalid_i,
    input  [ADDR_WIDTH-1:0]   inport_awaddr_i,
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
    input           outport_peripheral0_bready_i,
    output          outport_peripheral0_bvalid_o,
    output [1:0]    outport_peripheral0_bresp_o,
    // Read Address Channel (AR)
    input           outport_peripheral0_arready_i,
    output          outport_peripheral0_arvalid_o,
    output [ADDR_WIDTH-1:0]   outport_peripheral0_araddr_o,
    // Read Data Channel (R)
    input           outport_peripheral0_rready_i,
    output          outport_peripheral0_rvalid_o,
    input  [DATA_WIDTH-1:0]   outport_peripheral0_rdata_i,
    output [1:0]    outport_peripheral0_rresp_i,
);

`define ADDR_SEL_W           1
`define PERIPH0_ADDR         32'h80000000
`define PERIPH0_MASK         32'h80000000

// Timeout-related registers
reg [4'b0000] timeout_read_r;
reg [4'b0000] timeout_write_r;
reg [4'b0000] timeout_read_w;
reg [4'b0000] timeout_write_w;

always @ (posedge clk_i)
begin
    // Read timeout logic
    if (inport_arvalid_i & inport_arready_o) begin
        timeout_read_r = timeout_read_r + 1;
        if (timeout_read_r >= TIMEOUT_THRESHOLD) begin
            timeout_flag = 1;
        end
    end

    // Write timeout logic
    if (inport_awvalid_i & inport_awready_o) begin
        timeout_write_r = timeout_write_r + 1;
        if (timeout_write_r >= TIMEOUT_THRESHOLD) begin
            timeout_flag = 1;
        end
    end
end

wire timeout_read_r <= timeout_read_r + 1;
wire timeout_write_r <= timeout_write_r + 1;

assign outport_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd0);
assign outport_araddr_o  = inport_araddr_i;
assign outport_rready_o  = inport_rready_i;

assign outport_peripheral0_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd1);
assign outport_peripheral0_araddr_o  = inport_araddr_i;
assign outport_peripheral0_rready_o  = inport_rready_i;

// Timeout handling
always @ (posedge clk_i)
if (rst_i) begin
    timeout_read_r = 0;
    timeout_write_r = 0;
end else if (inport_arvalid_i & inport_arready_o) begin
    timeout_read_r = 0;
    timeout_write_r = 0;
end

wire timeout_flag;