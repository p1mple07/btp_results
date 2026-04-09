module precision_counter_axi #(
   parameter C_S_AXI_DATA_WIDTH = 32,
   parameter C_S_AXI_ADDR_WIDTH = 8
) (
   input  logic axi_aclk,
   input  logic axi_aresetn,
   // Write Address Channel
   input  logic [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
   input  logic axi_awvalid,
   output logic axi_awready,
   // Write Data Channel
   input  logic [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
   input  logic [(C_S_AXI_DATA_WIDTH/8)-1:0] axi_wstrb,
   input  logic axi_wvalid,
   output logic axi_wready,
   // Write Response Channel
   output logic axi_bvalid,
   output logic [1:0] axi_bresp,
   input  logic axi_bready,
   // Read Address Channel
   input  logic [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr,
   input  logic axi_arvalid,
   output logic axi_arready,
   // Read Data Channel
   output logic axi_rvalid,
   output logic [1:0] axi_rresp,
   output logic [C_S_AXI_DATA_WIDTH-1:0] axi_rdata,
   input  logic axi_rready,
   // Control Outputs
   output logic axi_ap_done,
   output logic irq
);

   //-------------------------------------------------------------------------
   // Internal registers corresponding to the register map
   //-------------------------------------------------------------------------
   logic [31:0] reg_ctl;       // slv_reg_ctl: Control register (bit0: start/stop)
   logic [31:0] reg_t;         // slv_reg_t:  Elapsed time counter
   logic [31:0] reg_v;         // slv_reg_v:  Countdown value
   logic [31:0] reg_irq_mask;  // slv_reg_irq_mask: Interrupt mask register
   logic [31:0] reg_irq_thresh;// slv_reg_irq_thresh: Interrupt threshold register

   //-------------------------------------------------------------------------
   // Write Channel FSM and Register Update
   //-------------------------------------------------------------------------
   // Signals used for write transaction FSM
   logic write_active;
   logic [C_S_AXI_ADDR_WIDTH-1:0] awaddr_reg;
   logic [C_S_AXI_DATA_WIDTH-1:0] wdata_reg;
   logic [(C_S_AXI_DATA_WIDTH/8)-1:0] wstrb_reg;
   logic write_error;

   always_ff @(posedge axi_aclk or negedge axi_aresetn) begin
      if (!axi_aresetn) begin
         write_active   <= 1'b0;
         axi_awready    <= 1'b0;
         axi_wready     <= 1'b0;
         axi_bvalid     <= 1'b0;
         axi_bresp      <= 2'b00;
         write_error    <= 1'b0;
      end
      else begin
         // When not busy, assert ready signals
         axi_awready <= ~write_active;
         axi_wready  <= ~write_active;
         
         // Initiate write transaction if both address and data are valid
         if (~write_active && axi_awvalid && axi_wvalid) begin
            awaddr_reg <= axi_awaddr;
            wdata_reg  <= axi_wdata;
            wstrb_reg  <= axi_wstrb;
            write_active <= 1'b1;
            axi_bvalid  <= 1'b1;
            // Decode the write address and update registers accordingly
            case (awaddr_reg)
               8'h00: begin
                  // Control register: start/stop countdown; reset elapsed time
                  write_error <= 1'b0;
                  reg_ctl     <= wdata_reg;
                  reg_t       <= 32'b0; // Reset elapsed time on control register write
               end
               8'h10: begin
                  // Elapsed time register
                  write_error <= 1'b0;
                  reg_t       <= wdata_reg;
               end
               8'h20: begin
                  // Countdown register
                  write_error <= 1'b0;
                  reg_v       <= wdata_reg;
               end
               8'h24: begin
                  // Interrupt mask register
                  write_error <= 1'b0;
                  reg_irq_mask <= wdata_reg;
               end
               8'h28: begin
                  // Interrupt threshold register
                  write_error <= 1'b0;
                  reg_irq_thresh <= wdata_reg;
               end
               default: begin
                  write_error <= 1'b1; // Unsupported address
               end
            endcase
         end
         // Complete the write transaction when the master is ready
         if (write_active && axi_bready) begin
            write_active <= 1'b0;
            axi_bvalid   <= 1'b0;
         end
         // Drive the write response based on the write_error flag
         if (write_active) begin
            axi_bresp <= (write_error ? 2'b10 : 2'b00);
         end
      end
   end

   //-------------------------------------------------------------------------
   // Countdown and Elapsed Time Update Logic
   //-------------------------------------------------------------------------
   // The countdown register (reg_v) is decremented by 1 every clock cycle
   // when the counter is running (control bit 0 is 1). When reg_v reaches 0,
   // the elapsed time register (reg_t) is incremented.
   always_ff @(posedge axi_aclk or negedge axi_aresetn) begin
      if (!axi_aresetn) begin
         reg_v <= 32'b0;
         reg_t <= 32'b0;
      end
      else if (!write_active) begin  // Only update when no write transaction is active
         if (reg_ctl[0] == 1) begin
            if (reg_v != 0)
               reg_v <= reg_v - 1;
            else
               reg_t <= reg_t + 1;
         end
      end
   end

   //-------------------------------------------------------------------------
   // Read Channel Combinational Logic
   //-------------------------------------------------------------------------
   always_comb begin
      // Always ready to accept a read address
      axi_arready = 1'b1;
      // Decode the read address and drive the read data accordingly
      case (axi_araddr)
         8'h00: axi_rdata = reg_ctl;
         8'h10: axi_rdata = reg_t;
         8'h20: axi_rdata = reg_v;
         8'h24: axi_rdata = reg_irq_mask;
         8'h28: axi_rdata = reg_irq_thresh;
         default: begin
            axi_rresp  = 2'b10;  // Error response for invalid address
            axi_rdata  = 32'b0;
         end
      endcase
      axi_rvalid = axi_arvalid;
   end

   //-------------------------------------------------------------------------
   // Control Output Assignments
   //-------------------------------------------------------------------------
   // axi_ap_done is asserted when the countdown value reaches 0 while running.
   assign axi_ap_done = (reg_v == 32'b0) && reg_ctl[0];

   // irq is asserted when:
   //   - The countdown value equals the interrupt threshold,
   //   - Interrupts are enabled (irq_mask bit0 is 1),
   //   - And the counter is running (control bit0 is 1).
   assign irq = (reg_v == reg_irq_thresh) && (reg_irq_mask[0] == 1) && reg_ctl[0];

endmodule