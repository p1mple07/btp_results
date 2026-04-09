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

  // Memory array for the FILO buffer
  logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];

  // Pointers and counters (using binary representation)
  logic [$clog2(DEPTH):0] w_ptr, r_ptr;  
  logic [$clog2(DEPTH):0] w_count_bin, r_count_bin;  
  // Synchronized pointers (converted to Gray code)
  logic [$clog2(DEPTH):0] wq2_rptr, rq2_wptr;  

  // Function: Convert binary to Gray code.
  function automatic logic [$clog2(DEPTH):0] bin_to_gray(input logic [$clog2(DEPTH):0] bin);
    bin_to_gray = bin ^ (bin >> 1);
  endfunction

  //////////////////////////////////////////////////////////////////////////////
  // Write Domain: Push Operation and Full Flag Logic
  //////////////////////////////////////////////////////////////////////////////
  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      w_count_bin <= 0;
      w_ptr       <= 0;
    end else begin
      // On push, if the FILO is not full, write data and update pointer/counter.
      if (push && !w_full) begin
        mem[w_ptr]   <= w_data;
        w_ptr        <= w_ptr + 1;
        w_count_bin  <= w_count_bin + 1;
      end
    end
  end

  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      w_full <= 0;
    end else begin
      // The FILO is full when the write counter reaches DEPTH.
      w_full <= (w_count_bin == DEPTH);
    end
  end

  //////////////////////////////////////////////////////////////////////////////
  // Read Domain: Pop Operation and Empty Flag Logic
  //////////////////////////////////////////////////////////////////////////////
  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_count_bin <= 0;
      r_ptr       <= 0;
    end else begin
      // On pop, if the FILO is not empty, read data and update pointer/counter.
      if (pop && !r_empty) begin
        r_data   <= mem[r_ptr];
        // Decrement pointer; since FIFO is non-empty, r_ptr will not be 0.
        r_ptr    <= r_ptr - 1;
        r_count_bin <= r_count_bin - 1;
      end
    end
  end

  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_empty <= 1;
    end else begin
      // The FILO is empty when the read counter is zero.
      r_empty <= (r_count_bin == 0);
    end
  end

  //////////////////////////////////////////////////////////////////////////////
  // Pointer Synchronization (Binary to Gray Code Conversion)
  //////////////////////////////////////////////////////////////////////////////
  // Sample the write pointer in the read clock domain.
  always_ff @(posedge r_clk) begin
    wq2_rptr <= bin_to_gray(w_ptr);
  end

  // Sample the read pointer in the write clock domain.
  always_ff @(posedge w_clk) begin
    rq2_wptr <= bin_to_gray(r_ptr);
  end

endmodule