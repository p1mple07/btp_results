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
    input [DATA_WIDTH-1:0] w_data,   // Data input for push
    output logic [DATA_WIDTH-1:0] r_data,   // Data output for pop
    output logic                  r_empty,  // Empty flag
    output logic                  w_full    // Full flag
);

  // Address width
  localparam ADDR_WIDTH = $clog2(DEPTH);

  // Address pointers
  logic [ADDR_WIDTH:0] w_ptr, r_ptr;
  logic [ADDR_WIDTH:0] w_ptr_next;
  logic [ADDR_WIDTH:0] r_ptr_next;

  logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];
  logic [ADDR_WIDTH-1:0] w_addr, r_addr;

  logic w_full_d1;

  // Removed unused signals

  // Reset handling
  always @(posedge w_clk) begin
    if (w_rst) begin
      w_ptr <= 0;
      w_full <= 0;
    end
  end

  always @(posedge r_clk) begin
    if (r_rst) begin
      r_ptr <= 0;
      r_empty <= 1;
    end
  end

  // Pointer increment and Gray encoding
  always @(posedge w_clk) begin
    if (push && !w_full) begin
      w_addr = w_addr + 1;
      w_ptr_next = w_ptr + 1;
      mem[w_ptr_next] <= w_data;
      w_full_d1 <= 1;
    end
  end

  always @(posedge r_clk) begin
    if (pop && ~r_empty) begin
      r_ptr_next = r_ptr + 1;
      r_data <= mem[r_ptr_next];
      r_empty <= 0;
    end
  end

  // Full flag calculation
  assign w_full = (w_count_next_bin[ADDR_WIDTH] != wq2_rptr_bin[ADDR_WIDTH]) &&
                  (w_count_next_bin[ADDR_WIDTH-1:0] == wq2_rptr_bin[ADDR_WIDTH-1:0]);

endmodule
