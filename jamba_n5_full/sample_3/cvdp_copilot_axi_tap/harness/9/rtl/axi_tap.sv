`timescale 1ns / 1ps

module axi_tap #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter TOUT_THRESHOLD = 1000
) (
    // Existing ports
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
    output          outport_rready_o
);

// Timeout counters for read and write transactions
reg [TOUT_THRESHOLD-1:0] read_tx_start;
reg [TOUT_THRESHOLD-1:0] write_tx_start;
reg read_tx_timeout;
reg write_tx_timeout;

// Timeout flags
reg read_tx_timeout_flag;
reg write_tx_timeout_flag;

always @(*) begin
    // Update start times when a transaction starts
    if (rst_i)
        read_tx_start <= {TOUT_THRESHOLD'b0};
        write_tx_start <= {TOUT_THRESHOLD'b0};
    else
        if (read_tx_start[0] < 0) begin
            read_tx_timeout <= 4'b1;
        end else read_tx_timeout <= read_tx_timeout + 4'b1;

        if (write_tx_start[0] < 0) begin
            write_tx_timeout <= 4'b1;
        end else write_tx_timeout <= write_tx_timeout + 4'b1;
    end

    // Check if the transaction has exceeded the threshold
    if (read_tx_timeout == TOUT_THRESHOLD)
        read_tx_timeout_flag <= 1'b1;
    else read_tx_timeout_flag <= 1'b0;

    if (write_tx_timeout == TOUT_THRESHOLD)
        write_tx_timeout_flag <= 1'b1;
    else write_tx_timeout_flag <= 1'b0;
end

// Additional logic for read and write channels remains unchanged
