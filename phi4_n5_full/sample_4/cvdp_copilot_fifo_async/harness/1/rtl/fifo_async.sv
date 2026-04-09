module fifo_async #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH      = 16
)(
  input  logic                     w_clk,
  input  logic                     w_rst,
  input  logic                     w_inc,
  input  logic [DATA_WIDTH-1:0]    w_data,
  input  logic                     r_clk,
  input  logic                     r_rst,
  input  logic                     r_inc,
  output logic                     w_full,
  output logic                     r_empty,
  output logic [DATA_WIDTH-1:0]    r_data
);

  // Determine pointer width: one extra bit for overflow
  localparam PTR_WIDTH = $clog2(DEPTH) + 1;

  // Internal pointer signals (binary and Gray)
  logic [PTR_WIDTH-1:0] w_ptr_bin_local; // Write pointer in binary
  logic [PTR_WIDTH-1:0] w_ptr_gray;       // Write pointer in Gray code

  logic [PTR_WIDTH-1:0] r_ptr_bin_local; // Read pointer in binary
  logic [PTR_WIDTH-1:0] r_ptr_gray;       // Read pointer in Gray code

  // Dual-port memory declaration
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Synchronizer signals for cross-clock pointer passing
  // Synchronizer for r_ptr from read to write domain
  logic [PTR_WIDTH-1:0] r_ptr_sync_stage0, r_ptr_sync_wire;
  // Synchronizer for w_ptr from write to read domain
  logic [PTR_WIDTH-1:0] w_ptr_sync_stage0, w_ptr_sync_wire;

  // Wires to pass pointer outputs from each domain
  wire [PTR_WIDTH-1:0] r_ptr_gray_from_read = r_ptr_gray;
  wire [PTR_WIDTH-1:0] w_ptr_gray_from_write = w_ptr_gray;

  // Binary conversion of synchronized pointers
  logic [PTR_WIDTH-1:0] r_ptr_sync_bin;
  logic [PTR_WIDTH-1:0] w_ptr_sync_bin;

  assign r_ptr_sync_bin = gray_to_bin(r_ptr_sync_wire);
  assign w_ptr_sync_bin = gray_to_bin(w_ptr_sync_wire);

  //----------------------------------------------------------------------------
  // Write Domain: Update write pointer, generate full flag, and write to memory
  //----------------------------------------------------------------------------
  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      w_ptr_bin_local <= 0;
      w_ptr_gray      <= 0;
      w_full          <= 0;
    end
    else begin
      // Increment write pointer if enabled and FIFO not full
      if (w_inc && !w_full) begin
        w_ptr_bin_local <= w_ptr_bin_local + 1;
        // Convert binary to Gray code: gray = binary ^ (binary >> 1)
        w_ptr_gray <= w_ptr_bin_local ^ (w_ptr_bin_local >> 1);
      end

      // Full flag calculation:
      // FIFO is full if the MSB (overflow bit) differs while lower bits are equal.
      w_full <= ((w_ptr_bin_local[PTR_WIDTH-1] != r_ptr_sync_bin[PTR_WIDTH-1]) &&
                 (w_ptr_bin_local[PTR_WIDTH-2:0] == r_ptr_sync_bin[PTR_WIDTH-2:0]));

      // Write data to memory if not full
      if (w_inc && !w_full)
        mem[w_ptr_bin_local] <= w_data;
    end
  end

  //----------------------------------------------------------------------------
  // Read Domain: Update read pointer, generate empty flag, and read from memory
  //----------------------------------------------------------------------------
  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_ptr_bin_local <= 0;
      r_ptr_gray      <= 0;
      r_empty         <= 0;
    end
    else begin
      // Increment read pointer if enabled and FIFO not empty
      if (r_inc && !r_empty) begin
        r_ptr_bin_local <= r_ptr_bin_local + 1;
        r_ptr_gray <= r_ptr_bin_local ^ (r_ptr_bin_local >> 1);
      end

      // Empty flag calculation:
      // FIFO is empty if the binary read pointer equals the synchronized write pointer.
      r_empty <= (r_ptr_bin_local == w_ptr_sync_bin);

      // Read data from memory if not empty
      if (r_inc && !r_empty)
        r_data <= mem[r_ptr_bin_local];
    end
  end

  //----------------------------------------------------------------------------
  // Synchronizer for r_ptr: Pass read pointer (Gray code) from read to write domain
  //----------------------------------------------------------------------------
  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst)
      r_ptr_sync_stage0 <= 0;
    else
      r_ptr_sync_stage0 <= r_ptr_gray_from_read; // Asynchronous capture from read domain
  end

  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst)
      r_ptr_sync_wire <= 0;
    else
      r_ptr_sync_wire <= r_ptr_sync_stage0;
  end

  //----------------------------------------------------------------------------
  // Synchronizer for w_ptr: Pass write pointer (Gray code) from write to read domain
  //----------------------------------------------------------------------------
  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst)
      w_ptr_sync_stage0 <= 0;
    else
      w_ptr_sync_stage0 <= w_ptr_gray_from_write; // Asynchronous capture from write domain
  end

  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst)
      w_ptr_sync_wire <= 0;
    else
      w_ptr_sync_wire <= w_ptr_sync_stage0;
  end

  //----------------------------------------------------------------------------
  // Function: Convert Gray code to binary
  //----------------------------------------------------------------------------
  function automatic [PTR_WIDTH-1:0] gray_to_bin(input [PTR_WIDTH-1:0] gray);
    integer i;
    logic [PTR_WIDTH-1:0] bin;
    begin
      bin = gray;
      for (i = PTR_WIDTH-2; i >= 0; i = i - 1)
        bin[i] = bin[i+1] ^ gray[i];
      gray_to_bin = bin;
    end
  endfunction

endmodule