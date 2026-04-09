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
  logic [15:0] count;
  logic [15:0] match_value;
  logic [15:0] reload_value;
  logic [31:0] control;
  logic [31:0] status;
  logic        match_flag;

  // Control register bit positions:
  // Bit 0: Enable (timer enabled when high)
  // Bit 1: Interval Mode (when high, counter reloads on match)
  // Bit 2: Interrupt Enable (when high, interrupt is generated)
  localparam CTRL_ENABLE      = 0;
  localparam CTRL_INTERVAL    = 1;
  localparam CTRL_INTERRUPT   = 2;

  // AXI Read Logic (combinational)
  always_comb begin
    case (axi_addr)
      4'h0: axi_rdata = {16'b0, count};         // Count Register (lower 16 bits)
      4'h1: axi_rdata = {16'b0, match_value};    // Match Value Register (lower 16 bits)
      4'h2: axi_rdata = {16'b0, reload_value};   // Reload Value Register (lower 16 bits)
      4'h3: axi_rdata = control;                 // Control Register
      4'h4: axi_rdata = status;                  // Status Register
      default: axi_rdata = 32'b0;
    endcase
  end

  // Main Sequential Logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset all registers and flags
      count          <= 16'b0;
      match_value    <= 16'b0;
      reload_value   <= 16'b0;
      control        <= 32'b0;
      status         <= 32'b0;
      match_flag     <= 1'b0;
    end
    else begin
      // Process AXI write operations
      if (axi_write_en) begin
        case (axi_addr)
          4'h1: match_value <= axi_wdata[15:0];  // Write lower 16 bits to Match Value Register
          4'h2: reload_value <= axi_wdata[15:0]; // Write lower 16 bits to Reload Value Register
          4'h3: control <= {28'b0, axi_wdata[CTRL_INTERRUPT:0]}; // Only lower 3 bits are used
          4'h4: begin
                   // Writing to Status Register clears the interrupt flag.
                   status <= axi_wdata;
                   match_flag <= 1'b0;
                end
          default: ; // Write to Count Register is not allowed (read-only)
        endcase
      end

      // Timer Operation: Increment count if enabled
      if (control[CTRL_ENABLE]) begin
        if (count == match_value) begin
          // Match event detected
          if (control[CTRL_INTERVAL])
            count <= reload_value;  // Interval Mode: reload to reload_value
          else
            count <= match_value;   // Non-Interval Mode: hold at match_value
        end
        else begin
          count <= count + 1;
        end
      end

      // Update match_flag if not cleared by a status write
      if (! (axi_write_en && (axi_addr == 4'h4))) begin
        if (count == match_value)
          match_flag <= 1'b1;
        else
          match_flag <= 1'b0;
      end

      // Update Status Register: bit0 reflects the interrupt status
      status[0] <= match_flag;
    end
  end

  // Interrupt Generation: Assert interrupt if match_flag is set and interrupt enable is active
  assign interrupt = match_flag & control[CTRL_INTERRUPT];

endmodule