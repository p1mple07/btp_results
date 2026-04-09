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
  input  [DATA_WIDTH-1:0]       w_data,   // Data input for push
  output logic [DATA_WIDTH-1:0] r_data,   // Data output for pop
  output logic                  r_empty,  // Empty flag
  output logic                  w_full    // Full flag
);

  // Memory array for the FILO buffer
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Binary pointers and counters (assumed DEPTH is a power-of-2)
  logic [$clog2(DEPTH):0] w_ptr, r_ptr;
  logic [$clog2(DEPTH):0] w_count_bin, r_count_bin;

  // Gray code pointers for synchronization between clock domains
  logic [$clog2(DEPTH):0] wq2_rptr, rq2_wptr;

  // Function: Convert binary to Gray code
  function automatic logic [$clog2(DEPTH):0] bin_to_gray(
    input logic [$clog2(DEPTH):0] bin
  );
    bin_to_gray = bin ^ (bin >> 1);
  endfunction

  // Function: Convert Gray code to binary
  function automatic logic [$clog2(DEPTH):0] gray_to_bin(
    input logic [$clog2(DEPTH):0] gray
  );
    logic [$clog2(DEPTH):0] bin;
    bin = gray;
    for (int i = $clog2(DEPTH); i > 0; i = i - 1) begin
      bin = bin ^ (bin >> i);
    end
    gray_to_bin = bin;
  endfunction

  // Write Domain: Push logic and pointer update
  always_ff @(posedge w_clk, posedge w_rst) begin
    if (w_rst) begin
      w_count_bin <= 0;
      w_ptr       <= 0;
    end else begin
      if (push && !w_full) begin
         // Write data into the buffer at the current write pointer location
         mem[w_ptr] <= w_data;
         // Increment the write pointer and counter
         w_ptr       <= w_ptr + 1;
         w_count_bin <= w_count_bin + 1;
      end
      // Generate the Gray code version of the write pointer for synchronization
      wq2_rptr <= bin_to_gray(w_ptr);
    end
  end

  // Read Domain: Pop logic and pointer update
  always_ff @(posedge r_clk, posedge r_rst) begin
    if (r_rst) begin
      r_count_bin <= 0;
      r_ptr       <= 0;
    end else begin
      if (pop && !r_empty) begin
         // Read data from the buffer at the current read pointer location
         r_data <= mem[r_ptr];
         // Decrement the read pointer and counter
         r_ptr       <= r_ptr - 1;
         r_count_bin <= r_count_bin - 1;
      end
      // Synchronize the write pointer from the write domain:
      // Capture the Gray code pointer (wq2_rptr) into read domain register rq2_wptr.
      rq2_wptr <= wq2_rptr;
    end
  end

  // Read Domain: Empty flag logic
  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_empty <= 1;  // Buffer is empty after reset
    end else begin
      // Convert the synchronized write pointer from Gray to binary
      // and compare with the read counter. If equal, buffer is empty.
      if (r_count_bin == gray_to_bin(rq2_wptr))
         r_empty <= 1;
      else
         r_empty <= 0;
    end
  end

  // Write Domain: Full flag logic
  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      w_full <= 0;  // Buffer is not full after reset
    end else begin
      // When the write counter reaches DEPTH, the buffer is full.
      if (w_count_bin == DEPTH)
         w_full <= 1;
      else
         w_full <= 0;
    end
  end

endmodule