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

  // Pointer width: one extra bit for overflow detection
  localparam PTR_WIDTH = $clog2(DEPTH) + 1;

  // Dual-port memory for FIFO storage (assumed dual-port)
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Binary pointers used for memory addressing
  logic [PTR_WIDTH-1:0] w_ptr_bin;
  logic [PTR_WIDTH-1:0] r_ptr_bin;

  // Gray-coded pointers
  logic [PTR_WIDTH-1:0] w_ptr_gray;
  logic [PTR_WIDTH-1:0] r_ptr_gray;

  // Synchronized Gray pointers across clock domains
  logic [PTR_WIDTH-1:0] r_ptr_gray_sync_stage1;
  logic [PTR_WIDTH-1:0] r_ptr_gray_sync;
  logic [PTR_WIDTH-1:0] w_ptr_gray_sync_stage1;
  logic [PTR_WIDTH-1:0] w_ptr_gray_sync;

  // Function: Convert binary to Gray code
  function automatic logic [PTR_WIDTH-1:0] bin2gray(input logic [PTR_WIDTH-1:0] bin);
    bin2gray = bin ^ (bin >> 1);
  endfunction

  // -------------------------------------------------------------------
  // Write Domain: Update write pointer and write data into FIFO memory
  // -------------------------------------------------------------------
  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      w_ptr_bin <= 0;
    end else begin
      if (w_inc && !w_full) begin
        mem[w_ptr_bin] <= w_data;
        w_ptr_bin <= w_ptr_bin + 1;
      end
    end
  end

  // Generate write pointer Gray code from binary pointer
  always_comb begin
    w_ptr_gray = bin2gray(w_ptr_bin);
  end

  // -------------------------------------------------------------------
  // Read Domain: Update read pointer and read data from FIFO memory
  // -------------------------------------------------------------------
  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_ptr_bin <= 0;
    end else begin
      if (r_inc && !r_empty) begin
        r_ptr_bin <= r_ptr_bin + 1;
      end
    end
  end

  // Generate read pointer Gray code from binary pointer
  always_comb begin
    r_ptr_gray = bin2gray(r_ptr_bin);
  end

  // -------------------------------------------------------------------
  // Cross-Domain Synchronization of Pointers
  // -------------------------------------------------------------------
  // Synchronize the read pointer Gray code from the read clock domain to the write clock domain
  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      r_ptr_gray_sync_stage1 <= 0;
      r_ptr_gray_sync        <= 0;
    end else begin
      r_ptr_gray_sync_stage1 <= r_ptr_gray;
      r_ptr_gray_sync        <= r_ptr_gray_sync_stage1;
    end
  end

  // Synchronize the write pointer Gray code from the write clock domain to the read clock domain
  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      w_ptr_gray_sync_stage1 <= 0;
      w_ptr_gray_sync        <= 0;
    end else begin
      w_ptr_gray_sync_stage1 <= w_ptr_gray;
      w_ptr_gray_sync        <= w_ptr_gray_sync_stage1;
    end
  end

  // -------------------------------------------------------------------
  // FIFO Status Flag Generation
  // -------------------------------------------------------------------
  // In the write domain, generate the full flag.
  // FIFO is considered full when the Gray-coded write pointer and the synchronized read pointer differ
  // and their most significant bits (MSB) are different.
  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      w_full <= 0;
    end else begin
      w_full <= ((w_ptr_gray != r_ptr_gray_sync) && (w_ptr_gray[PTR_WIDTH-1] != r_ptr_gray_sync[PTR_WIDTH-1]));
    end
  end

  // In the read domain, generate the empty flag.
  // FIFO is empty when the Gray-coded read pointer equals the synchronized write pointer.
  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_empty <= 0;
    end else begin
      r_empty <= (r_ptr_gray == w_ptr_gray_sync);
    end
  end

  // -------------------------------------------------------------------
  // Read Data Output
  // -------------------------------------------------------------------
  // Read data from the FIFO memory using the binary read pointer.
  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_data <= 0;
    end else if (r_inc && !r_empty) begin
      r_data <= mem[r_ptr_bin];
    end
  end

endmodule