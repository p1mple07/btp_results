`timescale 1ns/1ps

module axi4lite_to_pcie_cfg_bridge #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32  
) (
    // AXI4-Lite Interface
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

    // FSM States
    typedef enum logic [2:0] {
        IDLE,           
        ADDR_CAPTURE,  
        DATA_CAPTURE,  
        PCIE_READ,    
        SEND_RESPONSE  
    } state_t;

    state_t current_state, next_state;

    // Internal registers
    logic [ADDR_WIDTH-1:0] araddr_reg;  
    logic [DATA_WIDTH-1:0] rdata_reg;   
    logic [DATA_WIDTH/8-1:0]  rstrb_reg;   

    // FSM State Transition
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // FSM Next State Logic
    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (arvalid && arready) begin
                    next_state = ADDR_CAPTURE;
                end
            end

            ADDR_CAPTURE: begin
                next_state = PCIE_READ;
            end

            DATA_CAPTURE: begin
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
            bresp <= 2'b00;
            pcie_cfg_wr_en <= 1'b0;
            pcie_cfg_wdata <= 32'h0;
            pcie_cfg_addr <= 8'h0;
            araddr_reg <= 32'h0;
            rdata_reg <= 32'h0;
            rstrb_reg <= 4'h0;
        end else begin
            case (current_state)
                IDLE: begin
                    arready <= 1'b0;
                    rdata_reg <= 32'h0;
                    rstrb_reg <= 4'h0;
                end

                ADDR_CAPTURE: begin
                    awready <= 1'b1;
                    araddr_reg <= araddr;
                end

                DATA_CAPTURE: begin
                    rdata_reg <= pcie_cfg_rdata;
                    rstrb_reg <= wstrb;
                    rresp_reg <= 2'b0;
                    rvalid_reg <= 1'b0;
                    rready_reg <= 1'b0;
                end

                PCIE_READ: begin
                    pcie_cfg_addr <= araddr_reg[7:0];
                end

                SEND_RESPONSE: begin
                    bvalid <= 1'b1;
                end

                default: begin
                    // Default outputs
                end
            endcase
        end
    end

endmodule
