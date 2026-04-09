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

  // Determine address width based on DEPTH
  localparam ADDR_WIDTH = $clog2(DEPTH);

  // Write and read pointer registers (Gray-coded)
  logic [ADDR_WIDTH:0] w_ptr;
  logic [ADDR_WIDTH:0] r_ptr;
  logic [ADDR_WIDTH:0] w_ptr_next;
  logic [ADDR_WIDTH:0] r_ptr_next;

  // Memory array
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Removed unused signals:
  // - w_ptr_b1, r_ptr_1, w_full_f1, and the combinational always block driving w_full_d1

  // Instead of using a continuously driven wire for the write address,
  // we use a register (w_addr_reg) that holds the address for the memory write.
  logic [ADDR_WIDTH-1:0] w_addr_reg;

  // Gray code conversion functions
  function automatic [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] bin);
    bin2gray = bin ^ (bin >> 1);
  endfunction

  function automatic [ADDR_WIDTH:0] gray2bin(input [ADDR_WIDTH:0] gray);
    gray2bin = gray;
    for (int i = 1; i <= ADDR_WIDTH; i++)
      gray2bin[i] = gray2bin[i] ^ gray2bin[i-1];
  endfunction

  // Counters for write and read domains
  logic [ADDR_WIDTH:0] w_count_bin, r_count_bin;
  wire [ADDR_WIDTH:0] w_count_next_bin, r_count_next_bin;
  wire [ADDR_WIDTH:0] wq2_rptr_bin;

  // Write pointer and memory write update (single always block)
  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      w_count_bin <= 0;
      w_ptr       <= 0;
      w_addr_reg  <= 0;
    end
    else begin
      // Update counters and pointers
      w_count_bin <= w_count_next_bin;
      w_ptr       <= w_ptr_next;
      // Perform memory write using the address from the previous cycle
      if (push && !w_full)
        mem[w_addr_reg] <= w_data;
      // Update the write address register (using the old counter value)
      w_addr_reg <= w_count_bin[ADDR_WIDTH-1:0];
    end
  end

  // Write counter next value and pointer update
  assign w_count_next_bin = w_count_bin + ({(ADDR_WIDTH+1){push}} & ~{(ADDR_WIDTH+1){w_full}});
  assign w_ptr_next = bin2gray(w_count_next_bin);

  // Write full flag update
  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst)
      w_full <= 0;
    else
      w_full <= (w_count_next_bin[ADDR_WIDTH] != wq2_rptr_bin[ADDR_WIDTH]) &&
                (w_count_next_bin[ADDR_WIDTH-1:0] == wq2_rptr_bin[ADDR_WIDTH-1:0]);
  end

  // Gray pointer synchronization for write domain
  logic [ADDR_WIDTH:0] wq1_rptr, wq2_rptr;
  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      wq1_rptr <= 0;
      wq2_rptr <= 0;
    end
    else begin
      wq1_rptr <= r_ptr;
      wq2_rptr <= wq1_rptr;
    end
  end
  assign wq2_rptr_bin = gray2bin(wq2_rptr);

  // Read pointer update
  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_count_bin <= 0;
      r_ptr       <= 0;
    end
    else begin
      r_count_bin <= r_count_next_bin;
      r_ptr       <= r_ptr_next;
    end
  end

  // Read counter next value and pointer update
  assign r_count_next_bin = r_count_bin + ({(ADDR_WIDTH+1){pop}} & ~{(ADDR_WIDTH+1){r_empty}});
  assign r_ptr_next = bin2gray(r_count_next_bin);

  // Read address is derived from the read counter.
  // (Using a continuous assignment is acceptable here because r_count_bin is registered.)
  assign r_addr = r_count_bin[ADDR_WIDTH-1:0];
  assign r_data = mem[r_addr];

  // r_empty flag update: mark empty when the counter is zero.
  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst)
      r_empty <= 1;
    else
      r_empty <= (r_count_bin == 0);
  end

endmodule