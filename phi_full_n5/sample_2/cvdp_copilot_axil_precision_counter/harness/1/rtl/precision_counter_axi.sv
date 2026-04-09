module precision_counter_axi(
    input axi_aclk,
    input axi_aresetn,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    input [C_S_AXI_DATA_WIDTH/8-1:0] axi_wstrb,
    output reg axi_wvalid,
    output reg axi_wready,
    output reg axi_bvalid,
    output axi_bready,
    output reg axi_bresp,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr,
    input axi_arvalid,
    output reg axi_rready,
    output reg axi_rresp,
    output reg irq,
    output [C_S_AXI_DATA_WIDTH-1:0] axi_rdata,
    input [31:0] slv_reg_ctl,
    output reg slv_reg_v,
    input [31:0] slv_reg_t,
    input [31:0] slv_reg_irq_mask,
    input [31:0] slv_reg_irq_thresh
);

    reg [31:0] counter;
    reg [31:0] elapsed_time;
    reg [31:0] interrupt_mask;

    always @(posedge axi_aclk or posedge axi_aresetn) begin
        if (axi_aresetn) begin
            counter <= 0;
            elapsed_time <= 0;
            interrupt_mask <= 0;
            slv_reg_ctl <= 0;
            slv_reg_v <= 0;
            slv_reg_t <= 0;
            slv_reg_irq_mask <= 0;
            slv_reg_irq_thresh <= 0;
            irq <= 0;
            axi_wvalid <= 0;
            axi_wready <= 0;
            axi_bvalid <= 0;
            axi_bready <= 0;
            axi_bresp <= 0;
            axi_rvalid <= 0;
            axi_rready <= 0;
            axi_rdata <= 0;
            axi_rresp <= 0;
        end else begin
            if (axi_awvalid && axi_awready) begin
                case axi_awaddr is
                    0: slv_reg_ctl <= slv_reg_ctl | 1'b1; // Start countdown
                    default: axi_bresp <= 2'b10; // SLVERR for unrecognized address
                endcase
            end
            
            if (axi_wvalid && axi_wready) begin
                case axi_waddr is
                    0: slv_reg_v <= axi_wdata; // Write countdown value
                    default: axi_bresp <= 2'b10; // SLVERR for unrecognized address
                endcase
            end
        end
        
        if (axi_arvalid && axi_arready) begin
            case axi_araddr is
                0: axi_rdata <= slv_reg_v; // Read countdown value
                1: elapsed_time <= elapsed_time; // Read elapsed time
                2: interrupt_mask <= slv_reg_irq_mask; // Read interrupt mask
                3: irq <= irq; // Read interrupt status
                default: axi_rresp <= 2'b10; // SLVERR for unrecognized address
            end
        end
        
        if (axi_rvalid && axi_rready) begin
            axi_rdata <= slv_reg_t; // Read elapsed time
            axi_rresp <= 2'b00; // OKAY for valid read
        end
        
        if (counter == 0) begin
            axi_ap_done <= 1; // Countdown complete
        end else begin
            counter <= counter - 1; // Decrement counter
        end
        
        if (interrupt_mask && counter == slv_reg_irq_thresh) begin
            irq <= 1; // Trigger interrupt
        end
    end
    
    // AXI Write Response
    always @(posedge axi_bvalid) begin
        if (axi_bvalid) begin
            axi_bresp <= (axi_bready && 2'b00); // OKAY if ready, else SLVERR
        end
    end
    
    // AXI Read Response
    always @(posedge axi_rvalid) begin
        if (axi_rvalid) begin
            axi_rresp <= (axi_rready && 2'b00); // OKAY if ready, else SLVERR
        end
    end
endmodule