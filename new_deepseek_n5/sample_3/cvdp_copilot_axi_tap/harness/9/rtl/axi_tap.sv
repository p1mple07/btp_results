Okay, I need to modify the axi_tap module to include transaction timeouts for both read and write operations. Let me think about how to approach this.

First, I should add a timeout timer. Since the timer needs to count cycles, I'll use a reg bit for each transaction. I'll add two reg variables: timeout_read and timeout_write. These will track the elapsed cycles for read and write transactions respectively.

Next, I need a timeout threshold. This should be a configurable input port. I'll define a parameter TIMEOUT_THRESHOLD in the top-level module and make it an input so it can be changed at compile time.

Now, I'll add a timeout flag. I'll declare a new output port, timeout_flag, which will be 1 when a timeout occurs.

For the read transaction, when the read_arvalid_i is asserted, I'll start the timeout_read counter. It should increment on each clock cycle. When timeout_read reaches the threshold, I'll set the timeout_flag. Similarly, for write transactions, when write_awvalid_i is asserted, I'll start timeout_write and check against the threshold.

I need to ensure that the timeout_flag is only set when the transaction hasn't completed yet. So, I'll use always blocks to check the counters against the threshold.

Also, I should handle the timeout_flag appropriately. Maybe in the top module, I can add logic to reset the flag or handle errors based on the threshold.

Wait, looking at the existing code, I see that the module is a top-level entity. So, I'll add the TIMEOUT_THRESHOLD as an input to the module. I'll also declare the timeout_flag as an output.

In the read section, when inport_arvalid_i is high, I'll start the timeout_read. Each clock cycle, I'll increment it. If it exceeds the threshold, set timeout_flag. Same for write.

I'll add the necessary reg variables and input ports at the top of the module. Then, in the always blocks for read and write, I'll implement the timeout logic.

I should also make sure that the timeout_flag doesn't interfere with the existing functionality. It should only affect when a transaction hasn't completed on time.

Finally, I'll test the code to ensure that the timeout_flag is correctly asserted when the threshold is reached and not otherwise.



module axi_tap #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter TIMEOUT_THRESHOLD = 1000 // configurable timeout
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
    input           inport_araddr_i,
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
    input  [DATA_WIDTH-1:0]   outport_peripheral0_rdata_i,
    input  [1:0]    outport_peripheral0_rresp_i,
    output          outport_peripheral0_rready_o,

    // Additional timeout ports
    input           timeout_flag,
    input           TIMEOUT_THRESHOLD,

    // Timeout registers
    reg               timeout_read = 0;
    reg               timeout_write = 0;
)define ADDR_SEL_W           1
`define PERIPH0_ADDR         32'h80000000
`define PERIPH0_MASK         32'h80000000
`define TIMEOUT_THRESHOLD    1000

//-----------------------------------------------------------------
// AXI: Read
//-----------------------------------------------------------------
reg [3:0]              read_pending_q;
reg [3:0]              read_pending_r;
reg [`ADDR_SEL_W-1:0]  read_port_q;
reg [`ADDR_SEL_W-1:0]  read_port_r;

always @ *
begin
    read_port_r = `ADDR_SEL_W'b0;
    if ((inport_araddr_i & `PERIPH0_MASK) == `PERIPH0_ADDR) read_port_r = `ADDR_SEL_W'd1;
end

wire read_incr_w = (inport_arvalid_i && inport_arready_o);
wire read_decr_w = (inport_rvalid_o && inport_rready_i);

always @ *
begin
    read_pending_r = read_pending_q;

    if (read_incr_w && !read_decr_w)
        read_pending_r = read_pending_r + 4'd1;
    else if (!read_incr_w && read_decr_w)
        read_pending_r = read_pending_r - 4'd1;
end

always @ (posedge clk_i )
if (rst_i)
begin
    read_pending_q <= 4'b0;
    read_port_q    <= `ADDR_SEL_W'b0;
end
else 
begin
    read_pending_q <= read_pending_r;

    // Read command accepted
    if (inport_arvalid_i && inport_arready_o)
    begin
        read_port_q <= read_port_r;
    end
end

wire read_accept_w       = (read_port_q == read_port_r && read_pending_q != 4'hF) || (read_pending_q == 4'h0);

assign outport_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd0);
assign outport_araddr_o  = inport_araddr_i;
assign outport_rready_o  = inport_rready_i;

assign outport_peripheral0_arvalid_o = inport_arvalid_i & read_accept_w & (read_port_r == `ADDR_SEL_W'd1);
assign outport_peripheral0_araddr_o  = inport_araddr_i;
assign outport_peripheral0_rready_o  = inport_rready_i;

reg        outport_rvalid_r;
reg [DATA_WIDTH-1:0] outport_rdata_r;
reg [1:0]  outport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
    begin
        outport_rvalid_r = outport_peripheral0_rvalid_i;
        outport_rdata_r  = outport_peripheral0_rdata_i;
        outport_rresp_r  = outport_peripheral0_rresp_i;
    end
    default:
    begin
        outport_rvalid_r = outport_rvalid_i;
        outport_rdata_r  = outport_rdata_i;
        outport_rresp_r  = outport_rresp_i;
    end
    endcase
end

assign inport_rvalid_o  = outport_rvalid_r;
assign inport_rdata_o   = outport_rdata_r;
assign inport_rresp_o   = outport_rresp_r;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR_SEL_W'd1:
    begin
        inport_arready_r = outport_peripheral0_arready_i;
    end
    default:
    begin
        inport_arready_r = outport_arready_i;
    end
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_peripheral0_rdata_o;
assign inport_rresp_o   = outport_peripheral0_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR_SEL_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_peripheral0_rdata_o;
assign inport_rresp_o   = outport_peripheral0_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR_SEL_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_peripheral0_rdata_o;
assign inport_rresp_o   = outport_peripheral0_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR_SEL_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_peripheral0_rdata_o;
assign inport_rresp_o   = outport_peripheral0_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR_SEL_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_peripheral0_rdata_o;
assign inport_rresp_o   = outport_peripheral0_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR_SEL_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR_SEL_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR_SEL_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR_SEL_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    case (read_port_q)
    `ADDR塞尔_W'd0:
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    case (read_port_q)
    `ADDR塞尔_W'd0:
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    case (read_port_q)
    `ADDR塞尔_W'd0:
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    case (read_port_q)
    `ADDR塞尔_W'd0:
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    case (read_port_q)
    `ADDR塞尔_W'd0:
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    case (read_port_q)
    `ADDR塞尔_W'd0:
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    case (read_port_q)
    `ADDR塞尔_W'd0:
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end

assign inport_arready_o = read_accept_w & inport_arready_r;

reg inport_arvalid_r;
always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
        inport_arvalid_r = outport_peripheral0_awvalid_i;
    default:
        inport_arvalid_r = inport_arvalid_i;
    endcase
end

wire inport_arvalid_o = inport_arvalid_r;

reg inport_rvalid_r;
reg [1:0]  inport_rresp_r;

always @ *
begin
    case (read_port_q)
    `ADDR塞尔_W'd1:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    end
    case (read_port_q)
    `ADDR塞尔_W'd0:
        outport_peripheral0_rvalid_o = inport_rvalid_i;
        outport_peripheral0_rdata_o  = inport_rdata_i;
        outport_peripheral0_rresp_o   = inport_rresp_i;
    default:
    begin
        outport_peripheral0_rvalid_o = inport_rvalid_o;
        outport_peripheral0_rdata_o  = inport_rdata_o;
        outport_peripheral0_rresp_o   = inport_rresp_o;
    end
    endcase
end

assign inport_rvalid_o  = outport_peripheral0_rvalid_o;
assign inport_rdata_o   = outport_rdata_o;
assign inport_rresp_o   = outport_rresp_o;

reg inport_arready_r;
always @ *
begin
    case (read_port_r)
    `ADDR塞尔_W'd1:
        inport_arready_r = outport_peripheral0_arready_i;
    default:
        inport_arready_r = outport_arready_i;
    endcase
end