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
    input           outport_peripheral0_rready_o,
    input  [DATA_WIDTH-1:0]   outport_peripheral0_rdata_i
);

`define ADDR_SEL_W           1
`define PERIPH0_ADDR         32'h80000000
`define PERIPH0_MASK         32'h80000000

// Address matching and routing logic
always @ (posedge clk_i or negedge rst_i)
begin
    if (rst_i) begin
        // Clear pending transactions and interface selections
        read_pending_q <= 4'b0;
        write_pending_q <= 4'b0;
        read_port_q    <= `ADDR_SEL_W'b0;
        write_port_q    <= `ADDR_SEL_W'b0;
    end else begin
        // Match incoming address against the Peripheral0 mask
        if (inport_araddr_i && inport_awaddr_i) begin
            if (inport_araddr_i & PERIPH0_MASK == PERIPH0_ADDR) begin
                // Incoming address matches Peripheral0, route to Peripheral0
                write_port_q    <= `ADDR_SEL_W'd1;
                read_port_q     <= `ADDR_SEL_W'd1;
                read_accept_w   <= 1'b1;
                write_accept_w  <= 1'b1;
            end else begin
                // Incoming address does not match Peripheral0, route to Default Interface
                write_port_q    <= `ADDR_SEL_W'b0;
                read_port_q     <= `ADDR_SEL_W'b0;
                read_accept_w   <= 1'b0;
                write_accept_w  <= 1'b0;
            end
        end
    end
end

// Handshake logic for Peripheral0 interface
always @ (posedge clk_i or negedge rst_i)
begin
    if (rst_i) begin
        // Reset handshake signals for Peripheral0
        outport_peripheral0_awready_i <= 1'b0;
        outport_peripheral0_wready_i <= 1'b0;
        outport_peripheral0_rready_i <= 1'b0;
        outport_peripheral0_arready_i <= 1'b0;
        outport_peripheral0_bready_i <= 1'b0;
    end else begin
        // Update handshake signals based on interface selection
        if (write_port_q == 1'd1) begin
            outport_peripheral0_awready_i <= inport_awready_o & awvalid_q & write_accept_w;
            outport_peripheral0_wready_i <= inport_wready_o & wvalid_q & write_accept_w & (write_port_r == 1'd1);
            outport_peripheral0_rready_i <= inport_rready_o & read_valid_r;
        end else begin
            outport_peripheral0_awready_i <= 1'b0;
            outport_peripheral0_wready_i <= 1'b0;
            outport_peripheral0_rready_i <= 1'b0;
            outport_peripheral0_bready_i <= 1'b0;
        end
    end
end

// Handshake logic for Default Interface
// (Similar to Peripheral0 interface, omitted for brevity)

// Write channel logic for Default Interface
// (Similar to Peripheral0 interface, omitted for brevity)

// Read channel logic for Default Interface
// (Similar to Peripheral0 interface, omitted for brevity)

// Write channel logic for Peripheral0 interface
// (Similar to Default Interface, omitted for brevity)

// Read channel logic for Peripheral0 interface
// (Similar to Default Interface, omitted for brevity)

endmodule
