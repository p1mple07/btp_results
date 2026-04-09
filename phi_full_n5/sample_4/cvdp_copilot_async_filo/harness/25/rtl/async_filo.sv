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
    input                        [DATA_WIDTH-1:0] w_data,   // Data input for push
    output logic [DATA_WIDTH-1:0] r_data,   // Data output for pop
    output logic                  r_empty,  // Empty flag
    output logic                  w_full    // Full flag
);

  // Address width
  localparam ADDR_WIDTH = $clog2(DEPTH);

  // Address pointers
  logic [ADDR_WIDTH:0] w_ptr, r_ptr;
  logic [ADDR_WIDTH:0] w_ptr_next, r_ptr_next;
  logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];
  wire [ADDR_WIDTH-1:0] w_addr, r_addr;

  logic w_full;

  // Reset handling
  always @(posedge w_rst) begin
    w_ptr <= 0;
    r_ptr <= 0;
    w_full <= 0;
  end

  // Gray code conversion
  function automatic [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] bin);
    bin2gray = bin ^ (bin >> 1);
  endfunction

  function automatic [ADDR_WIDTH:0] gray2bin(input [ADDR_WIDTH:0] gray);
    gray2bin = gray;
    for (int i = 1; i <= ADDR_WIDTH; i++) gray2bin[i] = gray2bin[i] ^ gray2bin[i-1];
  endfunction

  // Write pointers
  always @(posedge w_clk) begin
    if (push && !w_full) begin
      w_addr <= w_addr + 1;
      mem[w_addr] <= w_data;
    end
  end

  // Read pointers
  always @(posedge r_clk) begin
    if (r_rst) begin
      r_ptr <= 0;
    end else begin
      r_ptr <= r_ptr_next;
    end
  end

  // Count pointers
  logic [ADDR_WIDTH:0] w_count_bin, r_count_bin;
  logic w_count_next_bin, r_count_next_bin;

  always @(posedge w_clk) begin
    if (w_rst) begin
      w_count_bin <= 0;
      w_ptr       <= 0;
      w_full      <= 0;
    end else begin
      w_count_bin <= w_count_next_bin;
      w_ptr       <= w_ptr_next;
      w_full      <= (w_count_next_bin[ADDR_WIDTH] != wq2_rptr_bin[ADDR_WIDTH]) && 
                      (w_count_next_bin[ADDR_WIDTH-1:0] == wq2_rptr_bin[ADDR_WIDTH-1:0]);
    end
  end

  always @(posedge r_clk) begin
    if (r_rst) begin
      r_count_bin <= 0;
      r_ptr       <= 0;
      r_empty     <= 1;
    end else begin
      r_count_bin <= r_count_next_bin;
      r_ptr       <= r_ptr_next;
      r_empty     <= (r_ptr_next == rq2_wptr);
    end
  end

endmodule
