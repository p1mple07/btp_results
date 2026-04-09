module interrupt_controller_apb #(
    parameter NUM_INTERRUPTS = 4,
    parameter ADDR_WIDTH     = 8
    )
    (
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [NUM_INTERRUPTS-1:0] interrupt_requests,
    output logic [NUM_INTERRUPTS-1:0] interrupt_service,
    output logic                      cpu_interrupt,
    input  logic                      cpu_ack,
    output logic [$clog2(NUM_INTERRUPTS)-1:0] interrupt_idx,
    output logic [ADDR_WIDTH-1:0]     interrupt_vector,
    
    // APB Interface Signals
    input  logic                      pclk,
    input  logic                      presetn,
    input  logic                      psel,
    input  logic                      penable,
    input  logic                      pwrite,
    input  logic [ADDR_WIDTH-1:0]     paddr,
    input  logic [31:0]               pwdata,
    output logic [31:0]               prdata,
    output logic                      pready
);

  //-------------------------------------------------------------------------
  // Internal Registers and Wires
  //-------------------------------------------------------------------------

  // Priority map: one entry per interrupt.
  // Each entry is 32 bits: Bits [7:0] = interrupt index, Bits [31:8] = priority.
  reg [31:0] priority_map [0:NUM_INTERRUPTS-1];

  // Vector table: one entry per interrupt.
  // Each entry is 32 bits: Bits [7:0] = interrupt index (not used), Bits [31:8] = vector address.
  reg [31:0] vector_table [0:NUM_INTERRUPTS-1];

  // Interrupt mask: one bit per interrupt.
  logic [NUM_INTERRUPTS-1:0] interrupt_mask;

  // Pending interrupts: updated when an interrupt request arrives and not masked.
  logic [NUM_INTERRUPTS-1:0] pending_interrupts;

  // Flag indicating that an interrupt is currently being serviced.
  logic servicing;

  // Register holding the index of the current interrupt being serviced.
  // When no valid interrupt is being serviced, this is set to an invalid value (-1).
  reg [$clog2(NUM_INTERRUPTS)-1:0] current_interrupt_reg;

  // APB read data register.
  reg [31:0] prdata_reg;

  // APB ready signal: asserted when a valid APB transaction is ongoing.
  assign pready = psel && penable;

  //-------------------------------------------------------------------------
  // Priority Arbitration Logic (Main Clock Domain)
  //-------------------------------------------------------------------------

  // Combinational block to select the highest priority pending interrupt.
  logic [$clog2(NUM_INTERRUPTS)-1:0] selected_interrupt;
  logic [31:0] selected_priority;
  always_comb begin
    selected_priority = 32'd0;
    selected_interrupt = '0;
    for (int i = 0; i < NUM_INTERRUPTS; i++) begin
      if (pending_interrupts[i]) begin
        // Compare the priority value (upper 24 bits) of each pending interrupt.
        if (priority_map[i][31:8] > selected_priority) begin
          selected_priority = priority_map[i][31:8];
          selected_interrupt = i;
        end
      end
    end
  end

  // Synchronous process for interrupt arbitration and pending update.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pending_interrupts <= '0;
      servicing          <= 1'b0;
      // Set current_interrupt_reg to an invalid value (-1 represented as all ones)
      current_interrupt_reg <= { $clog2(NUM_INTERRUPTS){1'b1} };
    end
    else begin
      // Update pending_interrupts: assert if a new request arrives and the interrupt is enabled.
      // Clear the pending bit when the current interrupt is acknowledged.
      for (int i = 0; i < NUM_INTERRUPTS; i++) begin
        if (interrupt_requests[i] && !interrupt_mask[i])
          pending_interrupts[i] <= 1'b1;
        else if (servicing && (current_interrupt_reg == i) && cpu_ack)
          pending_interrupts[i] <= 1'b0;
      end

      // If any interrupt is pending, select the highest priority one.
      if (|pending_interrupts)
        current_interrupt_reg <= selected_interrupt;
      else
        servicing <= 1'b0;
    end
  end

  // Drive the outputs for interrupt handling.
  assign cpu_interrupt   = servicing;
  assign interrupt_idx   = current_interrupt_reg;
  assign interrupt_vector = vector_table[current_interrupt_reg];
  // One-hot encoding: only the bit corresponding to the current interrupt is asserted.
  assign interrupt_service = (1 << current_interrupt_reg);

  //-------------------------------------------------------------------------
  // APB Interface Logic (pclk domain)
  //-------------------------------------------------------------------------

  // APB register access: writes update internal registers; reads return status.
  always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      // Reset internal registers to default values.
      for (int i = 0; i < NUM_INTERRUPTS; i++) begin
        // Default priority_map: sequential values (priority = i).
        priority_map[i] <= {24'd0, i};
        // Default vector_table: consecutive addresses (0x0, 0x4, ...).
        vector_table[i] <= 32'd0 + (i * 4);
      end
      // Default interrupt mask: all interrupts enabled.
      interrupt_mask <= '1;
      prdata_reg     <= 32'd0;
      // Reset current interrupt to an invalid value.
      current_interrupt_reg <= { $clog2(NUM_INTERRUPTS){1'b1} };
    end
    else if (psel && penable) begin
      case(paddr)
        8'h0: begin // REG_PRIORITY_MAP
          if (pwrite) begin
            // Write: use lower 8 bits of pwdata as index and upper 24 bits as new priority.
            int idx = pwdata[7:0];
            if (idx < NUM_INTERRUPTS)
              priority_map[idx] <= {pwdata[31:8], idx};
          end
          else begin
            // Read: return the priority for the current interrupt (if servicing), else 0.
            if (servicing)
              prdata_reg <= priority_map[current_interrupt_reg];
            else
              prdata_reg <= 32'd0;
          end
        end
        8'h1: begin // REG_INTERRUPT_MASK
          if (pwrite) begin
            // Write: update the mask (only lower NUM_INTERRUPTS bits are valid).
            interrupt_mask <= pwdata[0:NUM_INTERRUPTS-1];
          end
          else begin
            prdata_reg <= { {(32-NUM_INTERRUPTS){1'b0}}, interrupt_mask };
          end
        end
        8'h2: begin // REG_VECTOR_TABLE
          if (pwrite) begin
            // Write: use lower 8 bits of pwdata as index and upper 24 bits as new vector value.
            int idx = pwdata[7:0];
            if (idx < NUM_INTERRUPTS)
              vector_table[idx] <= {pwdata[31:8], 8'd0};
          end
          else begin
            // Read: return the vector for the current interrupt (if servicing), else 0.
            if (servicing)
              prdata_reg <= vector_table[current_interrupt_reg];
            else
              prdata_reg <= 32'd0;
          end
        end
        8'h3: begin // REG_PENDING
          // Read-only: return the pending interrupts.
          prdata_reg <= { {(32-NUM_INTERRUPTS){1'b0}}, pending_interrupts };
        end
        8'h4: begin // REG_CURRENT_INT
          // Read-only: return the index of the current interrupt being serviced.
          if (servicing)
            prdata_reg <= { {(24){1'b0}}, current_interrupt_reg };
          else
            // If no interrupt is being serviced, return an invalid index (all ones).
            prdata_reg <= 32'hffff_ffff;
        end
        default: begin
          prdata_reg <= 32'd0;
        end
      endcase
    end
  end

  assign prdata = prdata_reg;

endmodule