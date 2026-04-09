module implementing a high-precision countdown counter.
// This module supports start/stop control, countdown value updates, elapsed time tracking,
// and interrupt generation when the countdown value reaches a configurable threshold.
// The module adheres to the AXI4-Lite protocol with proper handshaking, flow control, and error handling.
// Register Map:
//   Offset 0x00: slv_reg_ctl      - Control register (bit0: start/stop countdown, writes reset elapsed time)
//   Offset 0x10: slv_reg_t        - Elapsed time counter
//   Offset 0x20: slv_reg_v        - Countdown value (decrements by 1 per clock when running)
//   Offset 0x24: slv_reg_irq_mask - Interrupt mask register (bit0 enables IRQ)
//   Offset 0x28: slv_reg_irq_thresh - Interrupt threshold register
// When the countdown reaches 0, axi_ap_done is asserted and elapsed time (slv_reg_t) is incremented.
// Interrupt (irq) is generated when reg_v equals reg_irq_thresh and interrupts are enabled.

module precision_counter_axi #
(
  parameter C_S_AXI_DATA_WIDTH = 32,
  parameter C_S_AXI_ADDR_WIDTH = 8
)
(
  input  wire                     axi_aclk,
  input  wire                     axi_aresetn,
  // Write Address Channel
  input  wire [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
  input  wire                     axi_awvalid,
  output reg                      axi_awready,
  // Write Data Channel
  input  wire [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
  input  wire [((C_S_AXI_DATA_WIDTH/8))-1:0] axi_wstrb,
  input  wire                     axi_wvalid,
  output reg                      axi_wready,
  // Write Response Channel
  output reg                      axi_bvalid,
  output reg [1:0]                axi_bresp,
  input  wire                     axi_bready,
  // Read Address Channel
  input  wire [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr,
  input  wire                     axi_arvalid,
  output reg                      axi_arready,
  // Read Data Channel
  output reg                      axi_rvalid,
  output reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata,
  output reg [1:0]                axi_rresp,
  input  wire                     axi_rready,
  // Control Outputs
  output reg                      axi_ap_done,
  output reg                      irq
);

  //-------------------------------------------------------------------------
  // Internal registers representing the device registers
  //-------------------------------------------------------------------------
  reg [31:0] reg_ctl;         // Control register (bit0: start/stop)
  reg [31:0] reg_t;           // Elapsed time counter
  reg [31:0] reg_v;           // Countdown value
  reg [31:0] reg_irq_mask;    // Interrupt mask register
  reg [31:0] reg_irq_thresh;  // Interrupt threshold register

  //-------------------------------------------------------------------------
  // FSM States for Write Channel
  //-------------------------------------------------------------------------
  localparam WRITE_IDLE  = 2'd0;
  localparam WRITE_WRITE = 2'd1;
  reg [1:0] write_state;
  reg [C_S_AXI_ADDR_WIDTH-1:0] awaddr_latched;

  //-------------------------------------------------------------------------
  // FSM States for Read Channel
  //-------------------------------------------------------------------------
  localparam READ_IDLE  = 2'd0;
  localparam READ_READ  = 2'd1;
  reg [1:0] read_state;
  reg [C_S_AXI_ADDR_WIDTH-1:0] araddr_latched;

  //-------------------------------------------------------------------------
  // AXI Write Channel FSM
  //-------------------------------------------------------------------------
  always @(posedge axi_aclk or negedge axi_aresetn) begin
    if (!axi_aresetn) begin
      axi_awready <= 1'b1;
      axi_wready  <= 1'b1;
      axi_bvalid  <= 1'b0;
      axi_bresp   <= 2'b00;
      write_state <= WRITE_IDLE;
      awaddr_latched <= {C_S_AXI_ADDR_WIDTH{1'b0}};
    end
    else begin
      case (write_state)
        WRITE_IDLE: begin
          axi_awready <= 1'b1;
          axi_wready  <= 1'b1;
          axi_bvalid  <= 1'b0;
          if (axi_awvalid) begin
            awaddr_latched <= axi_awaddr;
            write_state <= WRITE_WRITE;
            axi_awready <= 1'b0;
          end
        end
        WRITE_WRITE: begin
          axi_wready <= 1'b1;
          if (axi_wvalid && axi_wready) begin
            // Decode the latched address and perform the write operation.
            case (awaddr_latched)
              8'h00: begin
                reg_ctl <= axi_wdata;
                // Writing to control register resets the elapsed time.
                reg_t   <= 32'd0;
              end
              8'h10: begin
                reg_t <= axi_wdata;
              end
              8'h20: begin
                // If countdown is finished, restart it by clearing axi_ap_done and resetting elapsed time.
                if (reg_v == 32'd0) begin
                  reg_v   <= axi_wdata;
                  axi_ap_done <= 1'b0;
                  reg_t   <= 32'd0;
                end
                else begin
                  reg_v <= axi_wdata;
                end
              end
              8'h24: begin
                reg_irq_mask <= axi_wdata;
              end
              8'h28: begin
                reg_irq_thresh <= axi_wdata;
              end
              default: ; // Ignore writes to undefined addresses.
            endcase
            axi_wready <= 1'b0;
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b00;
            write_state <= WRITE_IDLE;
          end
        end
      endcase
      // Clear the write response once the master is ready.
      if (axi_bvalid && axi_bready)
        axi_bvalid <= 1'b0;
    end
  end

  //-------------------------------------------------------------------------
  // AXI Read Channel FSM
  //-------------------------------------------------------------------------
  always @(posedge axi_aclk or negedge axi_aresetn) begin
    if (!axi_aresetn) begin
      axi_arready <= 1'b1;
      axi_rvalid  <= 1'b0;
      axi_rresp   <= 2'b00;
      read_state  <= READ_IDLE;
      araddr_latched <= {C_S_AXI_ADDR_WIDTH{1'b0}};
      axi_rdata   <= {C_S_AXI_DATA_WIDTH{1'b0}};
    end
    else begin
      case (read_state)
        READ_IDLE: begin
          axi_arready <= 1'b1;
          axi_rvalid  <= 1'b0;
          if (axi_arvalid) begin
            araddr_latched <= axi_araddr;
            read_state <= READ_READ;
            axi_arready <= 1'b0;
          end
        end
        READ_READ: begin
          axi_rvalid <= 1'b1;
          axi_rresp  <= 2'b00;
          case (araddr_latched)
            8'h00: axi_rdata <= reg_ctl;
            8'h10: axi_rdata <= reg_t;
            8'h20: axi_rdata <= reg_v;
            8'h24: axi_rdata <= reg_irq_mask;
            8'h28: axi_rdata <= reg_irq_thresh;
            default: axi_rdata <= {C_S_AXI_DATA_WIDTH{1'b0}};
          endcase
          if (axi_rready) begin
            axi_rvalid <= 1'b0;
            axi_arready <= 1'b1;
            read_state <= READ_IDLE;
          end
        end
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Counter Logic: Decrement countdown and increment elapsed time after completion
  //-------------------------------------------------------------------------
  always @(posedge axi_aclk or negedge axi_aresetn) begin
    if (!axi_aresetn) begin
      reg_v   <= 32'd0;
      reg_t   <= 32'd0;
      axi_ap_done <= 1'b0;
    end
    else begin
      if (reg_ctl[0] == 1'b1) begin  // Countdown is running
        if (reg_v > 32'd0)
          reg_v <= reg_v - 1;
        else if (reg_v == 32'd0) begin
          axi_ap_done <= 1'b1;
          reg_t       <= reg_t + 1;  // Increment elapsed time after countdown completion
        end
      end
      else begin
        // When stopped, clear the done signal.
        axi_ap_done <= 1'b0;
      end
    end
  end

  //-------------------------------------------------------------------------
  // Interrupt Generation Logic
  // irq is asserted when:
  //   - The countdown is running (reg_ctl[0] == 1)
  //   - The countdown value equals the interrupt threshold (reg_v == reg_irq_thresh)
  //   - Interrupts are enabled (reg_irq_mask[0] == 1)
  //-------------------------------------------------------------------------
  always @(*) begin
    irq = (reg_ctl[0] == 1'b1) && (reg_v == reg_irq_thresh) && (reg_irq_mask[0] == 1'b1);
  end

endmodule