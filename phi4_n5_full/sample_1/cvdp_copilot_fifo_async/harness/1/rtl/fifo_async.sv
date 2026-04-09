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

  // Determine pointer widths. The binary pointer width is log2(DEPTH)
  // and the Gray pointer has one extra bit to track overflow.
  localparam PTR_WIDTH_BIN  = $clog2(DEPTH);
  localparam PTR_WIDTH_GRAY = PTR_WIDTH_BIN + 1;

  // FIFO memory array
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Write domain pointers (binary and Gray-coded)
  logic [PTR_WIDTH_BIN-1:0]  wr_ptr_bin;
  logic [PTR_WIDTH_GRAY-1:0] wr_ptr_gray;

  // Read domain pointers (binary and Gray-coded)
  logic [PTR_WIDTH_BIN-1:0]  rd_ptr_bin;
  logic [PTR_WIDTH_GRAY-1:0] rd_ptr_gray;

  // Cross-domain synchronizer outputs
  // rd_ptr_gray_sync is passed from the read domain to the write domain
  // wr_ptr_gray_sync is passed from the write domain to the read domain
  logic [PTR_WIDTH_GRAY-1:0] rd_ptr_gray_sync;
  logic [PTR_WIDTH_GRAY-1:0] wr_ptr_gray_sync;

  // Synchronizer registers in the write domain for rd_ptr_gray
  logic [PTR_WIDTH_GRAY-1:0] rd_ptr_gray_sync_stage0;
  logic [PTR_WIDTH_GRAY-1:0] rd_ptr_gray_sync_stage1;

  // Synchronizer registers in the read domain for wr_ptr_gray
  logic [PTR_WIDTH_GRAY-1:0] wr_ptr_gray_sync_stage0;
  logic [PTR_WIDTH_GRAY-1:0] wr_ptr_gray_sync_stage1;

  //----------------------------------------------------------------------------
  // Function: Convert binary to Gray code (for PTR_WIDTH_BIN bits)
  function automatic [PTR_WIDTH_BIN-1:0] bin_to_gray(
    input [PTR_WIDTH_BIN-1:0] bin
  );
    bin_to_gray = bin ^ (bin >> 1);
  endfunction

  // Function: Convert Gray code back to binary (for PTR_WIDTH_BIN bits)
  function automatic [PTR_WIDTH_BIN-1:0] gray_to_bin(
    input [PTR_WIDTH_BIN-1:0] gray
  );
    integer i;
    logic [PTR_WIDTH_BIN-1:0] bin;
    bin = gray;
    for(i = 1; i < PTR_WIDTH_BIN; i = i + 1) begin
      bin = bin ^ (bin >> i);
    end
    gray_to_bin = bin;
  endfunction

  // Function: Extended binary to Gray conversion.
  // The extra MSB is set to the MSB of the binary pointer.
  function automatic [PTR_WIDTH_GRAY-1:0] bin_to_gray_extended(
    input [PTR_WIDTH_BIN-1:0] bin
  );
    bin_to_gray_extended = { bin[PTR_WIDTH_BIN-1], bin ^ (bin >> 1) };
  endfunction

  // Function: Extended Gray to Binary conversion.
  // Reconstructs the binary pointer from the Gray-coded version.
  function automatic [PTR_WIDTH_BIN-1:0] gray_extended_to_bin(
    input [PTR_WIDTH_GRAY-1:0] gray
  );
    logic [PTR_WIDTH_BIN-1:0] lower_gray;
    lower_gray = gray[PTR_WIDTH_BIN-1:0];
    logic [PTR_WIDTH_BIN-1:0] bin;
    bin = gray_to_bin(lower_gray);
    bin[PTR_WIDTH_BIN-1] = gray[PTR_WIDTH_GRAY-1];
    gray_extended_to_bin = bin;
  endfunction
  //----------------------------------------------------------------------------
  // Write domain: Update write pointer and memory write.
  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      wr_ptr_bin      <= 0;
      wr_ptr_gray     <= 0;
      rd_ptr_gray_sync_stage0 <= 0;
      rd_ptr_gray_sync_stage1 <= 0;
    end
    else begin
      // Only write if not full.
      if (w_inc && !w_full) begin
        wr_ptr_bin <= wr_ptr_bin + 1;
        mem[wr_ptr_bin] <= w_data;
      end
      // Update the Gray-coded write pointer.
      wr_ptr_gray <= bin_to_gray_extended(wr_ptr_bin);
      // Synchronize the read pointer from the read domain.
      rd_ptr_gray_sync_stage0 <= rd_ptr_gray; // (Assume rd_ptr_gray is made available here)
      rd_ptr_gray_sync_stage1 <= rd_ptr_gray_sync_stage0;
    end
  end
  assign rd_ptr_gray_sync = rd_ptr_gray_sync_stage1;

  //----------------------------------------------------------------------------
  // Read domain: Update read pointer and memory read.
  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      rd_ptr_bin      <= 0;
      rd_ptr_gray     <= 0;
      wr_ptr_gray_sync_stage0 <= 0;
      wr_ptr_gray_sync_stage1 <= 0;
    end
    else begin
      // Only read if not empty.
      if (r_inc && !r_empty) begin
        rd_ptr_bin <= rd_ptr_bin + 1;
        r_data     <= mem[rd_ptr_bin];
      end
      // Update the Gray-coded read pointer.
      rd_ptr_gray <= bin_to_gray_extended(rd_ptr_bin);
      // Synchronize the write pointer from the write domain.
      wr_ptr_gray_sync_stage0 <= wr_ptr_gray; // (Assume wr_ptr_gray is made available here)
      wr_ptr_gray_sync_stage1 <= wr_ptr_gray_sync_stage0;
    end
  end
  assign wr_ptr_gray_sync = wr_ptr_gray_sync_stage1;

  //----------------------------------------------------------------------------
  // Full flag generation in the write domain.
  // FIFO is full when the difference between the write pointer and the synchronized
  // read pointer equals DEPTH - 1.
  assign w_full = (wr_ptr_bin - gray_extended_to_bin(rd_ptr_gray_sync) == DEPTH - 1);

  // Empty flag generation in the read domain.
  // FIFO is empty when the difference between the read pointer and the synchronized
  // write pointer is zero.
  assign r_empty = (rd_ptr_bin - gray_extended_to_bin(wr_ptr_gray_sync) == 0);

endmodule