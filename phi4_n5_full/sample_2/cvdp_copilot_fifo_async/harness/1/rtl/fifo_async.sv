fifo_async.sv
//------------------------------------------------------------------------------
// Asynchronous FIFO with Configurable Depth and Data Width
// Supports asynchronous writes (w_clk) and reads (r_clk) with cross‐domain
// synchronization using Gray-coded pointers.
//
// Parameters:
//   DATA_WIDTH - width of the data bus
//   DEPTH      - number of data elements that can be stored
//
// Interface:
//   Write domain:
//     w_clk   - write clock
//     w_rst   - asynchronous write reset
//     w_inc   - write enable
//     w_data  - data to be stored
//     w_full  - indicates FIFO is full
//
//   Read domain:
//     r_clk   - read clock
//     r_rst   - asynchronous read reset
//     r_inc   - read enable
//     r_data  - data output
//     r_empty - indicates FIFO is empty
//
// Behavior:
//   - Write and read pointers are maintained as binary counters with an extra
//     bit for overflow. The binary pointer is converted to Gray code for safe
//     cross-domain comparison.
//   - The FIFO is empty when the write and read pointers are exactly equal.
//   - The FIFO is full when, aside from the overflow (MSB) bit, the pointers
//     are equal but the MSB differs.
//   - Two-stage synchronizers pass the Gray-coded pointers across clock domains.
//------------------------------------------------------------------------------

module fifo_async #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH      = 16
)(
  input  logic         w_clk,
  input  logic         w_rst,
  input  logic         w_inc,
  input  logic [DATA_WIDTH-1:0] w_data,
  input  logic         r_clk,
  input  logic         r_rst,
  input  logic         r_inc,
  output logic         w_full,
  output logic         r_empty,
  output logic [DATA_WIDTH-1:0] r_data
);

  //-------------------------------------------------------------------------
  // Local Parameters
  //-------------------------------------------------------------------------
  // Pointer width: log2(DEPTH) + 1 (extra bit for overflow)
  localparam PTR_WIDTH = $clog2(DEPTH) + 1;

  //-------------------------------------------------------------------------
  // Write Domain: Pointer and Gray Code Conversion
  //-------------------------------------------------------------------------
  // Binary write pointer (including overflow bit)
  reg [PTR_WIDTH-1:0] w_ptr_bin;
  // Lower bits used as memory index
  wire [PTR_WIDTH-2:0] w_ptr_index = w_ptr_bin[PTR_WIDTH-2:0];

  // Convert binary pointer to Gray code.
  // g[PTR_WIDTH-1] = b[PTR_WIDTH-1]
  // For i = PTR_WIDTH-2 downto 0: g[i] = b[i+1] XOR b[i]
  wire [PTR_WIDTH-1:0] w_ptr_gray;
  genvar i;
  generate
    for (i = 0; i < PTR_WIDTH; i = i + 1) begin : w_gray_conv
      if (i == PTR_WIDTH-1)
        assign w_ptr_gray[i] = w_ptr_bin[PTR_WIDTH-1];
      else
        assign w_ptr_gray[i] = w_ptr_bin[i+1] ^ w_ptr_bin[i];
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Read Domain: Pointer and Gray Code Conversion
  //-------------------------------------------------------------------------
  // Binary read pointer (including overflow bit)
  reg [PTR_WIDTH-1:0] r_ptr_bin;
  // Lower bits used as memory index
  wire [PTR_WIDTH-2:0] r_ptr_index = r_ptr_bin[PTR_WIDTH-2:0];

  // Convert binary pointer to Gray code.
  wire [PTR_WIDTH-1:0] r_ptr_gray;
  genvar j;
  generate
    for (j = 0; j < PTR_WIDTH; j = j + 1) begin : r_gray_conv
      if (j == PTR_WIDTH-1)
        assign r_ptr_gray[j] = r_ptr_bin[PTR_WIDTH-1];
      else
        assign r_ptr_gray[j] = r_ptr_bin[j+1] ^ r_ptr_bin[j];
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Cross-Clock Synchronizers for Pointers
  //-------------------------------------------------------------------------
  // Synchronize read pointer (Gray) into write clock domain (2-stage)
  reg [PTR_WIDTH-1:0] r_ptr_gray_sync_w [1:0];
  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst)
      r_ptr_gray_sync_w[0] <= '0;
    else
      r_ptr_gray_sync_w[0] <= r_ptr_gray;
  end
  always_ff @(posedge w_clk) begin
    r_ptr_gray_sync_w[1] <= r_ptr_gray_sync_w[0];
  end

  // Synchronize write pointer (Gray) into read clock domain (2-stage)
  reg [PTR_WIDTH-1:0] w_ptr_gray_sync_r [1:0];
  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst)
      w_ptr_gray_sync_r[0] <= '0;
    else
      w_ptr_gray_sync_r[0] <= w_ptr_gray;
  end
  always_ff @(posedge r_clk) begin
    w_ptr_gray_sync_r[1] <= w_ptr_gray_sync_r[0];
  end

  //-------------------------------------------------------------------------
  // FIFO Full and Empty Flag Generation
  //-------------------------------------------------------------------------
  // In the write domain, the FIFO is full if:
  //   - The Gray-coded write pointer and the synchronized read pointer are not equal,
  //   - Their MSB (overflow bit) differ, and
  //   - Their lower bits are equal.
  assign w_full = (w_ptr_gray != r_ptr_gray_sync_w[1]) &&
                  (w_ptr_gray[PTR_WIDTH-1] != r_ptr_gray_sync_w[1][PTR_WIDTH-1]) &&
                  (w_ptr_gray[PTR_WIDTH-2:0] == r_ptr_gray_sync_w[1][PTR_WIDTH-2:0]);

  // In the read domain, the FIFO is empty if the synchronized write pointer equals the read pointer.
  assign r_empty = (w_ptr_gray_sync_r[1] == r_ptr_gray);

  //-------------------------------------------------------------------------
  // Memory Array
  //-------------------------------------------------------------------------
  // Dual-port memory to store FIFO data
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  //-------------------------------------------------------------------------
  // Write Operations (w_clk domain)
  //-------------------------------------------------------------------------
  // Update write pointer: increment normally; when reaching DEPTH-1, set overflow bit.
  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst)
      w_ptr_bin <= '0;
    else if (w_inc && !w_full) begin
      if (w_ptr_bin == DEPTH - 1)
        w_ptr_bin <= {1'b1, {(PTR_WIDTH-1){1'b0}}};
      else
        w_ptr_bin <= w_ptr_bin + 1;
    end
  end

  // Write data into memory at the address given by the lower bits of the pointer.
  always_ff @(posedge w_clk) begin
    if (w_inc && !w_full)
      mem[w_ptr_index] <= w_data;
  end

  //-------------------------------------------------------------------------
  // Read Operations (r_clk domain)
  //-------------------------------------------------------------------------
  // Update read pointer: increment normally; when reaching DEPTH-1, set overflow bit.
  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst)
      r_ptr_bin <= '0;
    else if (r_inc && !r_empty) begin
      if (r_ptr_bin == DEPTH - 1)
        r_ptr_bin <= {1'b1, {(PTR_WIDTH-1){1'b0}}};
      else
        r_ptr_bin <= r_ptr_bin + 1;
    end
  end

  // Read data from memory at the address given by the lower bits of the pointer.
  always_ff @(posedge r_clk) begin
    if (r_inc && !r_empty)
      r_data <= mem[r