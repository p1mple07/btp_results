module async_filo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 8
) (
    input                         w_clk,    // Write clock
    input                         w_rst,    // Write reset
    input                         push,     // Push signal
    input                         r_rst,    // Read reset
    input                         r_clk,    // Read clock
    input                         pop,      // Pop signal
    input        [DATA_WIDTH-1:0] w_data,   // Data input for push
    output logic [DATA_WIDTH-1:0] r_data,   // Data output for pop
    output logic                  r_empty,  // Empty flag
    output logic                  w_full    // Full flag
);

  // Calculate address width based on FIFO depth
  localparam ADDR_WIDTH = $clog2(DEPTH);

  // FIFO memory
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Binary counters used to derive Gray-coded pointers
  logic [ADDR_WIDTH:0] w_count_bin, r_count_bin;
  wire [ADDR_WIDTH:0] w_count_next_bin, r_count_next_bin;
  wire [ADDR_WIDTH:0] w_ptr_next, r_ptr_next;

  // Gray-coded pointers
  logic [ADDR_WIDTH:0] w_ptr, r_ptr;
  
  // Derived addresses (lower bits of binary counters)
  wire [ADDR_WIDTH-1:0] w_addr;
  wire [ADDR_WIDTH-1:0] r_addr;
  
  assign w_addr = w_count_bin[ADDR_WIDTH-1:0];
  assign r_addr = r_count_bin[ADDR_WIDTH-1:0];

  // FIFO status flags
  logic r_empty, w_full;

  // Cross-domain pointer synchronizers
  logic [ADDR_WIDTH:0] wq1_rptr, wq2_rptr;
  logic [ADDR_WIDTH:0] rq1_wptr, rq2_wptr;

  // Functions for Gray code conversion
  function automatic [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] bin);
    bin2gray = bin ^ (bin >> 1);
  endfunction

  function automatic [ADDR_WIDTH:0] gray2bin(input [ADDR_WIDTH:0] gray);
    gray2bin = gray;
    for (int i = 1; i <= ADDR_WIDTH; i++)
      gray2bin[i] = gray2bin[i] ^ gray2bin[i-1];
  endfunction

  //--------------------------------------------------------------------------
  // Write Domain: Update write counter and pointer
  //--------------------------------------------------------------------------

  // Next count: increment on push if not full
  assign w_count_next_bin = w_count_bin + ({(ADDR_WIDTH+1){push}} & ~{(ADDR_WIDTH+1){w_full}});
  // Convert binary count to Gray code for pointer
  assign w_ptr_next = bin2gray(w_count_next_bin);

  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      w_count_bin <= 0;
      w_ptr       <= 0;
    end else begin
      w_count_bin <= w_count_next_bin;
      w_ptr       <= w_ptr_next;
    end
  end

  //--------------------------------------------------------------------------
  // Read Domain: Update read counter and pointer
  //--------------------------------------------------------------------------

  // Next count: increment on pop if not empty
  assign r_count_next_bin = r_count_bin + ({(ADDR_WIDTH+1){pop}} & ~{(ADDR_WIDTH+1){r_empty}});
  // Convert binary count to Gray code for pointer
  assign r_ptr_next = bin2gray(r_count_next_bin);

  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_count_bin <= 0;
      r_ptr       <= 0;
    end else begin
      r_count_bin <= r_count_next_bin;
      r_ptr       <= r_ptr_next;
    end
  end

  //--------------------------------------------------------------------------
  // Cross-Domain Synchronization: Write Domain
  //--------------------------------------------------------------------------

  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      wq1_rptr <= 0;
      wq2_rptr <= 0;
    end else begin
      wq1_rptr <= r_ptr;
      wq2_rptr <= wq1_rptr;
    end
  end

  //--------------------------------------------------------------------------
  // Cross-Domain Synchronization: Read Domain
  //--------------------------------------------------------------------------

  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      rq1_wptr <= 0;
      rq2_wptr <= 0;
    end else begin
      rq1_wptr <= w_ptr;
      rq2_wptr <= rq1_wptr;
    end
  end

  //--------------------------------------------------------------------------
  // Write Operation: Store data into memory when push and not full
  //--------------------------------------------------------------------------

  always @(posedge w_clk) begin
    if (push && !w_full) begin
      mem[w_addr] <= w_data;
    end
  end

  //--------------------------------------------------------------------------
  // Read Operation: Output data from memory
  //--------------------------------------------------------------------------

  assign r_data = mem[r_addr];

  //--------------------------------------------------------------------------
  // FIFO Full Flag: Write Domain
  //--------------------------------------------------------------------------

  // Convert synchronized read pointer (wq2_rptr) from Gray to binary for comparison
  wire [ADDR_WIDTH:0] wq2_rptr_bin;
  assign wq2_rptr_bin = gray2bin(wq2_rptr);

  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      w_full <= 0;
    end else begin
      w_full <= (w_count_next_bin[ADDR_WIDTH] != wq2_rptr_bin[ADDR_WIDTH]) &&
                 (w_count_next_bin[ADDR_WIDTH-1:0] == wq2_rptr_bin[ADDR_WIDTH-1:0]);
    end
  end

  //--------------------------------------------------------------------------
  // FIFO Empty Flag: Read Domain
  //--------------------------------------------------------------------------

  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_empty <= 1;
    end else begin
      r_empty <= (r_ptr_next == rq2_wptr);
    end
  end

endmodule