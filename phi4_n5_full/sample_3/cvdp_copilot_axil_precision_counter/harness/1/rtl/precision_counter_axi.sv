// File: rtl/precision_counter_axi.sv
// This module implements a configurable AXI4-Lite Slave interface for a high‐precision countdown counter.
// It supports software control via read/write transactions, start/stop control, countdown value updates,
// elapsed time tracking, interrupt generation based on a configurable threshold, and proper AXI4-Lite handshaking.

module precision_counter_axi #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 8
) (
    input  wire                     axi_aclk,
    input  wire                     axi_aresetn,
    // AXI Write Address Channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input  wire                     axi_awvalid,
    // AXI Write Data Channel
    input  wire [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] axi_wstrb,
    input  wire                     axi_wvalid,
    output reg                      axi_awready,
    output reg                      axi_wready,
    output reg                      axi_bvalid,
    output reg [1:0]                axi_bresp,
    // AXI Read Address Channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr,
    input  wire                     axi_arvalid,
    output reg                      axi_arready,
    // AXI Read Data Channel
    output reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata,
    output reg [1:0]                axi_rresp,
    output reg                      axi_rvalid,
    input  wire                     axi_rready,
    // Control Outputs
    output reg                      axi_ap_done,
    output reg                      irq
);

    // Internal registers implementing the register map
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_ctl;       // Control register (offset 0x00)
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_t;         // Elapsed time counter (offset 0x10)
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_v;         // Countdown value (offset 0x20)
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_irq_mask;  // Interrupt mask (offset 0x24)
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_irq_thresh;// Interrupt threshold (offset 0x28)

    // Write transaction state machine
    localparam IDLE    = 2'b00;
    localparam ADDR_WAIT = 2'b01;
    localparam DATA_WAIT = 2'b10;
    localparam RESP    = 2'b11;
    reg [1:0] state;
    reg [C_S_AXI_ADDR_WIDTH-1:0] write_addr;

    // Read transaction temporary registers
    reg [C_S_AXI_ADDR_WIDTH-1:0] raddr;
    reg rerror;

    // AXI Write Transaction FSM
    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            state           <= IDLE;
            write_addr      <= 0;
            axi_awready     <= 0;
            axi_wready      <= 0;
            axi_bvalid      <= 0;
            axi_bresp       <= 2'b00;
        end else begin
            case (state)
                IDLE: begin
                    if (axi_awvalid && !axi_awready) begin
                        write_addr <= axi_awaddr;
                        state      <= ADDR_WAIT;
                        axi_awready<= 1;
                    end else begin
                        axi_awready<= 0;
                    end
                end
                ADDR_WAIT: begin
                    if (axi_wvalid && !axi_wready) begin
                        // Ensure a full write (all bytes valid)
                        if (axi_wstrb != {C_S_AXI_DATA_WIDTH/8{1'b1}}) begin
                            axi_bresp <= 2'b10;  // Error: Partial write not supported
                        end else begin
                            case (write_addr)
                                8'h00: begin
                                    slv_reg_ctl <= axi_wdata;
                                    slv_reg_t   <= 0; // Reset elapsed time on control write
                                    axi_bresp   <= 2'b00;
                                end
                                8'h10: begin
                                    slv_reg_t <= axi_wdata;
                                    axi_bresp <= 2'b00;
                                end
                                8'h20: begin
                                    slv_reg_v <= axi_wdata;
                                    axi_bresp <= 2'b00;
                                end
                                8'h24: begin
                                    slv_reg_irq_mask <= axi_wdata;
                                    axi_bresp <= 2'b00;
                                end
                                8'h28: begin
                                    slv_reg_irq_thresh <= axi_wdata;
                                    axi_bresp <= 2'b00;
                                end
                                default: begin
                                    axi_bresp <= 2'b10; // Error: Invalid address
                                end
                            endcase
                        end
                        state      <= DATA_WAIT;
                        axi_wready <= 1;
                        axi_bvalid <= 1;
                    end else begin
                        axi_wready <= 0;
                    end
                end
                DATA_WAIT: begin
                    if (axi_bready) begin
                        axi_bvalid <= 0;
                        state      <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    // AXI Read Transaction FSM
    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            raddr      <= 0;
            rerror     <= 0;
            axi_arready<= 0;
            axi_rvalid <= 0;
            axi_rresp  <= 2'b00;
        end else begin
            // Capture read address when valid
            if (axi_arvalid && !axi_arready) begin
                raddr <= axi_araddr;
                axi_arready <= 1;
            end else begin
                axi_arready <= 0;
            end

            // Provide read data when address is captured
            if (axi_arready && axi_arvalid) begin
                case (raddr)
                    8'h00: begin
                        axi_rdata <= slv_reg_ctl;
                        rerror    <= 0;
                        axi_rresp <= 2'b00;
                    end
                    8'h10: begin
                        axi_rdata <= slv_reg_t;
                        rerror    <= 0;
                        axi_rresp <= 2'b00;
                    end
                    8'h20: begin
                        axi_rdata <= slv_reg_v;
                        rerror    <= 0;
                        axi_rresp <= 2'b00;
                    end
                    8'h24: begin
                        axi_rdata <= slv_reg_irq_mask;
                        rerror    <= 0;
                        axi_rresp <= 2'b00;
                    end
                    8'h28: begin
                        axi_rdata <= slv_reg_irq_thresh;
                        rerror    <= 0;
                        axi_rresp <= 2'b00;
                    end
                    default: begin
                        axi_rdata <= 32'h0;
                        rerror    <= 1;
                        axi_rresp <= 2'b10;
                    end
                endcase
                axi_rvalid <= 1;
            end else if (axi_rready) begin
                axi_rvalid <= 0;
            end
        end
    end

    // Countdown and Elapsed Time Logic
    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            slv_reg_v   <= 0;
            slv_reg_t   <= 0;
            axi_ap_done <= 0;
        end else begin
            if (slv_reg_ctl[0] == 1) begin  // Countdown running
                if (slv_reg_v != 0) begin
                    slv_reg_v <= slv_reg_v - 1;
                end else begin
                    // Countdown reached 0: assert done pulse and increment elapsed time
                    axi_ap_done <= 1;
                    slv_reg_t   <= slv_reg_t + 1;
                end
            end else begin
                axi_ap_done <= 0;
            end
        end
    end

    // Interrupt Generation Logic
    // The irq signal is asserted when the countdown value equals the interrupt threshold
    // and interrupts are enabled (bit0 of slv_reg_irq_mask is 1).
    always @(*) begin
        if (!