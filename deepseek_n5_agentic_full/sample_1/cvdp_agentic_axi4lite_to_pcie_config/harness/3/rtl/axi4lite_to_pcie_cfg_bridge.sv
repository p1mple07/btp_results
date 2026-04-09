input  logic [ADDR_WIDTH-1:0] araddr;  // Read address
     input  logic        arvalid;        // Read address validity

output logic [1:0]  rready;          // Read readiness indicator
     output logic        rdata;           // Read data result
     output logic        rvalid;          // Read data validity

enum logic [4:0] { IDLE, ADDR_CAPTURE, PCIE_READ, SEND_RESPONSE, DONE } state_t;

// FSM Next State Logic
     always_comb begin
         next_state = current_state;
         case (current_state)
             IDLE: begin
                 if (arvalid && !rvalid) begin
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
                 if (rready) begin
                     next_state = DONE;
                 end
             end
             DONE: begin
                 next_state = IDLE;
             end
             default: begin
                 next_state = IDLE;
             end
         endcase
     end

awaddr_reg <= awaddr;  // Not used in read mode
     wdata_reg remains unused
     wstrb_reg remains unused

pcie_cfg_wr_en <= 1'b0;
     bvalid <= 1'b0;

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
                 ADDR_CAPTURE: begin
                     awready <= 1'b1;
                     awaddr_reg <= awaddr;
                 end
                 PCIE_READ: begin
                     rdata <= pcie_cfg_rdata;
                     rvalid <= 1'b1;
                     rready <= 1'b0;
                 end
                 SEND_RESPONSE: begin
                     rready <= 1'b1;
                     rvalid <= 1'b0;
                     bvalid <= 1'b1;
                     bresp <= 2'b01; // Acknowledge read operation
                 end
                 default: begin
                     // Default outputs
                 end
             endcase
         end
     end