module ttc_counter_lite (
  input  logic         clk,
  input  logic         reset,
  input  logic [3:0]   axi_addr,
  input  logic [31:0]  axi_wdata,
  input  logic         axi_write_en,
  input  logic         axi_read_en,
  output logic [31:0]  axi_rdata,
  output logic         interrupt
);

  //-------------------------------------------------------------------------
  // Register Definitions
  //-------------------------------------------------------------------------
  // All registers are 32-bit wide, but only the lower 16 bits are used.
  reg [31:0] count_reg;
  reg [31:0] match_value_reg;
  reg [31:0] reload_value_reg;
  reg [31:0] control_reg;
  reg [31:0] status_reg;

  //-------------------------------------------------------------------------
  // Control Register Bit Positions
  //-------------------------------------------------------------------------
  parameter ENABLE_BIT         = 0;
  parameter INTERVAL_MODE_BIT   = 1;
  parameter INTERRUPT_ENABLE_BIT= 2;

  //-------------------------------------------------------------------------
  // AXI-Lite Read Data Assignment
  //-------------------------------------------------------------------------
  always_comb begin
    unique case (axi_addr)
      4'h0: axi_rdata = count_reg;              // Count Register (lower 16 bits)
      4'h1: axi_rdata = match_value_reg;         // Match Value Register (lower 16 bits)
      4'h2: axi_rdata = reload_value_reg;        // Reload Value Register (lower 16 bits)
      4'h3: axi_rdata = control_reg;             // Control Register
      4'h4: axi_rdata = status_reg;              // Status Register
      default: axi_rdata = 32'd0;
    endcase
  end

  //-------------------------------------------------------------------------
  // Sequential Logic: Synchronous Operations
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset all registers and clear the interrupt flag.
      count_reg        <= 32'd0;
      match_value_reg  <= 32'd0;
      reload_value_reg <= 32'd0;
      control_reg      <= 32'd0;
      status_reg       <= 32'd0;
    end
    else begin
      //-------------------------------------------------------------------------
      // Process AXI-Lite Write Operations
      //-------------------------------------------------------------------------
      if (axi_write_en) begin
        unique case (axi_addr)
          4'h0: begin
                   // Count register is read-only; ignore writes.
                 end
          4'h1: begin
                   // Write to Match Value Register (only lower 16 bits used)
                   match_value_reg <= axi_wdata;
                 end
          4'h2: begin
                   // Write to Reload Value Register (only lower 16 bits used)
                   reload_value_reg <= axi_wdata;
                 end
          4'h3: begin
                   // Write to Control Register (enable, interval mode, interrupt enable)
                   control_reg <= axi_wdata;
                 end
          4'h4: begin
                   // Write to Status Register clears the interrupt flag.
                   // We update all bits except bit 0 is forced to 0.
                   status_reg <= {axi_wdata[31:1], 1'b0};
                 end
          default: ; // No operation for undefined addresses.
        endcase
      end

      //-------------------------------------------------------------------------
      // Timer/Counter Logic
      //-------------------------------------------------------------------------
      if (control_reg[ENABLE_BIT]) begin
        // Compute next count value.
        logic [31:0] next_count;
        next_count = count_reg + 1;

        // Check for match using the lower 16 bits.
        if (next_count[15:0] == match_value_reg[15:0]) begin
          // A match event has occurred.
          if (control_reg[INTERVAL_MODE_BIT]) begin
            // In interval mode, reload the counter.
            next_count = reload_value_reg;
          end
          else begin
            // In non-interval mode, hold the counter at the match value.
            next_count = match_value_reg;
          end
          // Set the match flag (interrupt flag) in the status register.
          status_reg <= 1;
        end
        else begin
          // No match event; clear the match flag.
          status_reg <= 0;
        end

        // Update the counter with the computed value.
        count_reg <= next_count;
      end
      // If not enabled, the counter remains unchanged.
    end
  end

  //-------------------------------------------------------------------------
  // Interrupt Output Assignment
  //-------------------------------------------------------------------------
  // The interrupt is asserted if the match flag is set and interrupts are enabled.
  assign interrupt = status_reg[0] & control_reg[INTERRUPT_ENABLE_BIT];

endmodule