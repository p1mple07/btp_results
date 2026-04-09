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
    output [1:0]    inport_rresp_o,
    output          inport_arvalid_o,
    output          inport_arready_o,
    output          inport_rvalid_o,
    output  [DATA_WIDTH-1:0]   inport_rdata_o,
    output [1:0]    inport_rresp_o,
    output          outport_awvalid_o,
    output  [ADDR_WIDTH-1:0]   outport_awaddr_o,
    output          outport_wvalid_o,
    output  [DATA_WIDTH-1:0]   outport_wdata_o,
    output  [3:0]    outport_wstrb_o,
    output          outport_wready_o,
    output          outport_bvalid_o,
    output [1:0]    outport_bresp_o,
    output          outport_bready_o,
    output          outport_arvalid_o,
    output          outport_arready_o,
    output          outport_rvalid_o,
    output  [DATA_WIDTH-1:0]   outport_rdata_o,
    output [1:0]    outport_rresp_o
);

// Address decoding variables
reg [3:0]    address_mask = 32'h80000000;
reg [3:0]    peripheral_address = 32'h00000000;

// FIFO for out-of-order transactions
reg [3:0]    read_pending_q;
reg [3:0]    read_pending_r;
reg [`address_mask-1:0]  read_port_q;
reg [`address_mask-1:0]  read_port_r;

// Read channel FIFO
reg [3:0]    write_port_q;
reg [3:0]    write_port_r;
reg [3:0]    write_response_q;
reg [3:0]    write_response_r;

// Control signals
reg read_accept_w;
reg write_accept_w;
reg write_accept_r;
reg write_data_ready_q;
reg write_data_ready_r;

always @ (posedge clk_i)
begin
    if (rst_i) begin
        // Initialize FIFO
        read_pending_q <= 4'b0;
        read_port_q    <= `address_mask'b0;
        write_port_q    <= 4'b0;
        write_response_q <= 4'b0;
        write_data_ready_q <= 4'b0;
    end
    else begin
        // Update FIFO states
        read_pending_q <= read_pending_r;
        read_port_q    <= read_port_r;
        write_port_q    <= write_port_r;
        write_response_q <= write_response_r;
        write_data_ready_q <= write_data_ready_r;
    end
end

// Read channel logic
always @ (posedge clk_i)
begin
    if (rst_i) begin
        read_pending_q <= 4'b0;
        read_port_q    <= `address_mask'b0;
        write_port_q    <= 4'b0;
        write_response_q <= 4'b0;
        write_data_ready_q <= 4'b0;
    end
    else begin
        if (inport_arvalid_i && inport_arready_o) begin
            read_port_q <= read_port_r;
        end
        if (inport_rvalid_i && inport_rready_o && !write_data_ready_q) begin
            write_port_q <= write_port_r;
        end
    end
end

// Write channel logic
always @ (posedge clk_i)
begin
    if (rst_i) begin
        read_pending_q <= 4'b0;
        read_port_q    <= `address_mask'b0;
        write_port_q    <= 4'b0;
        write_response_q <= 4'b0;
        write_data_ready_q <= 4'b0;
    end
    else begin
        if (inport_awvalid_i && inport_awready_o) begin
            write_port_q <= write_port_r;
        end
        if (inport_wvalid_i && inport_wready_o && !read_data_ready_q) begin
            write_response_q <= write_response_r;
        end
    end
end

// Backpressure logic
always @ (posedge clk_i)
begin
    if (rst_i) begin
        read_accept_w <= 1'b0;
        write_accept_w <= 1'b0;
    end
    else begin
        read_accept_w <= (read_port_q == read_port_r && read_pending_q != 4'hF) || (read_pending_q == 4'h0);
        write_accept_w <= (write_port_q == write_port_r && write_data_ready_q != 4'hF) || (write_data_ready_q == 4'h0);
    end
end

// Response forwarding
always @ (posedge clk_i)
begin
    if (rst_i) begin
        outport_arvalid_o <= 1'b0;
        outport_arready_o <= 1'b0;
        outport_rvalid_o <= 1'b0;
        outport_rready_o <= 1'b0;
    end
    else begin
        case (write_port_q)
            `address_mask'd1:
                outport_arvalid_o <= inport_arvalid_i & read_accept_w & (read_port_r == `address_mask'd1);
                outport_arready_o <= inport_arready_i;
                outport_rvalid_o <= inport_rvalid_i;
                outport_rready_o <= inport_rready_i;
            default:
                outport_arvalid_o <= inport_arvalid_i & read_accept_w & (read_port_r == `address_mask'd0);
                outport_arready_o <= inport_arready_i;
                outport_rvalid_o <= inport_rvalid_i;
                outport_rready_o <= inport_rready_i;
        endcase
    end
end

// FIFO initialization
reg [3:0]    read_pending_init = 4'h0;
reg [3:0]    read_port_init = 4'h0;
reg [3:0]    write_port_init = 4'h0;
reg [3:0]    write_response_init = 4'h0;
reg [3:0]    write_data_ready_init = 4'h0;

always @ (posedge clk_i)
begin
    if (rst_i) begin
        read_pending_init <= 4'h0;
        read_port_init <= 4'h0;
        write_port_init <= 4'h0;
        write_response_init <= 4'h0;
        write_data_ready_init <= 4'h0;
    end
    else begin
        read_pending_q <= read_pending_init;
        read_port_q    <= read_port_init;
        write_port_q    <= write_port_init;
        write_response_q <= write_response_init;
        write_data_ready_q <= write_data_ready_init;
    end
end

// Final cleanup
always @ (posedgeclk_i)
begin
    if (rst_i) begin
        read_port_init <= 4'h0;
        write_port_init <= 4'h0;
        write_response_init <= 4'h0;
        write_data_ready_init <= 4'h0;
    end
end

// Module ports
module axi peripheral0 (
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
    output [1:0]    inport_rresp_o,
    output          inport_arvalid_o,
    output          inport_arready_o,
    output          inport_rvalid_o,
    output  [DATA_WIDTH-1:0]   inport_rdata_o,
    output [1:0]    inport_rresp_o,
    output          outport_awvalid_o,
    output  [ADDR_WIDTH-1:0]   outport_awaddr_o,
    output          outport_wvalid_o,
    output  [DATA_WIDTH-1:0]   outport_wdata_o,
    output  [3:0]    outport_wstrb_o,
    output          outport_wready_o,
    output          outport_bvalid_o,
    output [1:0]    outport_bresp_o,
    output          outport_bready_o,
    output          outport_arvalid_o,
    output          outport_arready_o,
    output          outport_rvalid_o,
    output  [DATA_WIDTH-1:0]   outport_rdata_o,
    output [1:0]    outport_rresp_o
);

// Initialize FIFO
initial begin
    read_port_init = 4'h0;
    write_port_init = 4'h0;
    write_response_init = 4'h0;
    write_data_ready_init = 4'h0;
end