module ttc_counter_lite (
  input  logic                  clk,
  input  logic                  reset,
  input  logic [3:0]            axi_addr,
  input  logic [31:0]           axi_wdata,
  input  logic                  axi_write_en,
  input  logic                  axi_read_en,
  output logic [31:0]           axi_rdata,
  output logic                  interrupt
);

  // Control register bit positions
  localparam CTRL_ENABLE        = 0;
  localparam CTRL_INTERVAL_MODE = 1;
  localparam CTRL_INT_ENABLE    = 2;

  // Internal registers
  reg [31:0] count;         // Counter register (only lower 16 bits used)
  reg [31:0] match_value;   // Match value register (lower 16 bits used)
  reg [31:0] reload_value;  // Reload value register (lower 16 bits used)
  reg [31:0] control;       // Control register
  reg         match_flag;   // Flag set when counter matches match_value
  reg [31:0] old_count;     // Used to detect counter transition
  reg [31:0] status;        // Status register (bit0 = interrupt status)

  // Counter update: increments when enabled, and on match event either reloads (interval mode)
  // or holds (non-interval mode). old_count is captured at the beginning of each cycle.
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      count      <= 32'd0;
      old_count  <= 32'd0;
    end else begin
      old_count <= count;  // capture previous count value for match detection
      if (control[CTRL_ENABLE]) begin
        if (count == match_value) begin
          if (control[CTRL_INTERVAL_MODE])
            count <= reload_value;  // reload on match in interval mode
          else
            count <= match_value;   // hold at match value in non-interval mode
        end else begin
          count <= count + 1;        // normal increment
        end
      end
    end
  end

  // Match detection: set match_flag when counter transitions from (match_value-1) to match_value.
  // Note: if the counter is already at match_value, no new match is generated.
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      match_flag <= 1'b0;
    else if (control[CTRL_ENABLE] && (old_count + 1 == match_value) && (count == match_value))
      match_flag <= 1'b1;
    // match_flag remains asserted until cleared by writing to the status register.
  end

  // AXI-Lite write operations: update registers based on axi_addr.
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      match_value <= 32'd0;
      reload_value<= 32'd0;
      control     <= 32'd0;
      // status will be cleared by its own always_ff block below.
    end else if (axi_write_en) begin
      case (axi_addr)
        4'h0: begin
          // Count Register: update lower 16 bits.
          count[15:0] <= axi_wdata[15:0];
        end
        4'h1: begin
          // Match Value Register: update lower 16 bits.
          match_value[15:0] <= axi_wdata[15:0];
        end
        4'h2: begin
          // Reload Value Register: update lower 16 bits.
          reload_value[15:0] <= axi_wdata[15:0];
        end
        4'h3: begin
          // Control Register: update enable, interval mode, and interrupt enable bits.
          control[CTRL_ENABLE]       <= axi_wdata[0];
          control[CTRL_INTERVAL_MODE] <= axi_wdata[1];
          control[CTRL_INT_ENABLE]   <= axi_wdata[2];
        end
        4'h4: begin
          // Status Register: writing clears the interrupt status and match_flag.
          match_flag <= 1'b0;
          // status will be updated in its own always_ff block.
        end
        default: ; // No operation for undefined addresses.
      endcase
    end
  end

  // Status register update: reflects the current interrupt status.
  // Writing to the status register (address 4'h4) clears the interrupt.
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      status <= 32'd0;
    else
      status <= {31'd0, match_flag};
  end

  // AXI-Lite read operations: return register values based on axi_addr.
  always_comb begin
    axi_rdata = 32'd0;
    case (axi_addr)
      4'h0: axi_rdata = {16'd0, count[15:0]};    // Count Register (lower 16 bits)
      4'h1: axi_rdata = {16'd0, match_value[15:0]}; // Match Value Register (lower 16 bits)
      4'h2: axi_rdata = {16'd0, reload_value[15:0]}; // Reload Value Register (lower 16 bits)
      4'h3: axi_rdata = control;                    // Control Register
      4'h4: axi_rdata = status;                     // Status Register
      default: axi_rdata = 32'd0;
    endcase
  end

  // Interrupt generation: assert interrupt output when match_flag is set and interrupt enable is active.
  assign interrupt = match_flag && control[CTRL_INT_ENABLE];

endmodule