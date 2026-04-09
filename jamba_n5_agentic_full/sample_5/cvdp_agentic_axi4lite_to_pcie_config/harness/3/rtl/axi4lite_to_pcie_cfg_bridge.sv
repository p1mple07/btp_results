`timescale 1ns/1ps

module axi4lite_to_pcie_cfg_bridge #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    // AXI4‑Lite Interface
    input  logic        aclk,
    input  logic        aresetn,
    input  logic [ADDR_WIDTH-1:0] awaddr,
    input  logic        awvalid,
    output logic        awready,
    input  logic [DATA_WIDTH-1:0] wdata,
    input  logic [DATA_WIDTH/8-1:0]  wstrb,
    input  logic        wvalid,
    output logic        wready,
    output logic [1:0]  bresp,
    output logic        bvalid,
    input  logic        bready,

    // PCIe Configuration Space Interface
    output logic [ADDR_WIDTH/4-1:0]  pcie_cfg_addr,  
    output logic [DATA_WIDTH-1:0] pcie_cfg_wdata, 
    output logic        pcie_cfg_wr_en, 
    input  logic [DATA_WIDTH-1:0] pcie_cfg_rdata, 
    input  logic        pcie_cfg_rd_en  
);

    // Read Ports
    input logic [ADDR_WIDTH-1:0] araddr;
    input logic        arvalid;
    output logic        arready;
    input logic [DATA_WIDTH-1:0] rdata;
    input logic        rvalid;
    output logic        rready;
    input logic [2:0]  rresp;

    // Internal State Variables
    state_t current_state, next_state;

    // State Definitions
    typedef enum logic [2:0] {
        IDLE,
        ARDY,
        PCIE_READ,
        SEND_RESPONSE
    } state_t;

    // Internal Registers
    logic [ADDR_WIDTH-1:0] awaddr_reg;  
    logic [DATA_WIDTH-1:0] wdata_reg;   
    logic [DATA_WIDTH/8-1:0]  wstrb_reg;   

    // FSM State Transition Logic
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Next State Assignment
    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (arvalid) begin
                    next_state = ADDR_CAPTURE;
                end
            end

            ADDR_CAPTURE: begin
                next_state = PCIE_READ;
            end

            PCIE_READ: begin
                next_state = SEND_RESPONSE;
            end

            SEND_RESPONSE: begin
                if (bready) begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // FSM Output Logic
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            awready <= 1'b0;
            wready <= 1'b0;
            bvalid <= 1'b0;
            bresp <= 2'b00; // OKAY response
            pcie_cfg_wr_en <= 1'b0;
            pcie_cfg_wdata <= 32'h0;
            pcie_cfg_addr <= 8'h0;
            awaddr_reg <= 32'h0;
            wdata_reg <= 32'h0;
            wstrb_reg <= 4'h0;
        end else begin
            case (current_state)
                IDLE: begin
                    awready <= 1'b0;
                    wready <= 1'b0;
                    bvalid <= 1'b0;
                    pcie_cfg_wr_en <= 1'b0;
                end

                ARDY: begin
                    arready <= 1'b1;
                    awaddr_reg <= awaddr;
                end

                PCIE_READ: begin
                    pcie_cfg_wr_en <= 1'b1;
                    pcie_cfg_addr <= awaddr_reg[7:0]; // 8-bit PCIe address

                    // Simulate a read operation: return dummy data
                    pcie_cfg_wdata <= 32'h0;
                    pcie_cfg_wr_en <= 1'b1;
                end

                SEND_RESPONSE: begin
                    pcie_cfg_wr_en <= 1'b0;
                    bvalid <= 1'b1;
                end

                default: begin
                    // Default outputs
                end
            endcase
        end
    end

endmodule
