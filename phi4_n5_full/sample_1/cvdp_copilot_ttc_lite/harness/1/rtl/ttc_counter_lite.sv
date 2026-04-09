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

  // Internal registers
  // The counter, match_value, and reload_value are 16-bit wide.
  reg  [15:0] count;
  reg  [15:0] match_value;
  reg  [15:0] reload_value;
  // Control register: bit0 = Enable, bit1 = Interval Mode, bit2 = Interrupt Enable.
  reg  [31:0] control;
  // Status register: bit0 = Interrupt status.
  reg  [31:0] status;
  // match_flag indicates that a match event has occurred.
  reg         match_flag;
  // old_count holds the previous cycle's counter value for match detection.
  reg  [15:0] old_count;

  // Main always_ff block: Handles AXI write operations, timer update, and match detection.
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      count        <= 16'd0;
      match_value  <= 16'd0;
      reload_value <= 16'd0;
      control      <= 32'd0;
      status       <= 32'd0;
      match_flag   <= 1'b0;
      old_count    <= 16'd0;
    end
    else begin
      // AXI Write Operations
      if (axi_write_en) begin
        case (axi_addr)
          4'h0: begin
            // Count Register is read-only; ignore writes.
          end
          4'h1: begin
            match_value <= axi_wdata[15:0];
          end
          4'h2: begin
            reload_value <= axi_wdata[15:0];
          end
          4'h3: begin
            control <= axi_wdata;
          end
          4'h4: begin
            status <= axi_wdata;
            // Writing a 0 to bit0 clears the interrupt flag.
            if (axi_wdata[0] == 1'b0)
              match_flag <= 1'b0;
          end
          default: begin
            // Invalid address; no operation.
          end
        endcase
      end

      // Timer Operation: Update counter if enabled.
      if (control[0]) begin  // if timer is enabled
        if (count == match_value) begin
          if (control[1]) begin
            // Interval mode: Reload counter to reload_value on match.
            count <= reload_value;
          end
          else begin
            // Non-interval mode: Hold counter at match_value.
            count <= count; // no change
          end
        end
        else begin
          // Normal increment.
          count <= count + 1;
        end
      end

      // Match Detection:
      // Detect a transition to the match value.
      if (control[0]) begin  // only check when timer is enabled
        if ((count == match_value) && (old_count != match_value))
          match_flag <= 1'b1;
        // In interval mode, when the counter is not at match_value, clear the flag.
        else if (control[1] && (count != match_value))
          match_flag <= 1'b0;
      end

      // Update old_count with the value of count from the beginning of the clock cycle.
      old_count <= count;
    end
  end

  // AXI Read Logic: Generate read data based on the current register values.
  always_comb begin
    // Default assignment.
    axi_rdata = 32'd0;
    case (axi_addr)
      4'h0: axi_rdata = {16'd0, count};          // Count Register (lower 16 bits)
      4'h1: axi_rdata = {16'd0, match_value};      // Match Value Register
      4'h2: axi_rdata = {16'd0, reload_value};     // Reload Value Register
      4'h3: axi_rdata = control;                   // Control Register
      4'h4: axi_rdata = status;                    // Status Register
      default: axi_rdata = 32'd0;
    endcase
  end

  // Interrupt Generation: Assert interrupt if a match event is flagged and interrupts are enabled.
  assign interrupt = match_flag & control[2];

endmodule