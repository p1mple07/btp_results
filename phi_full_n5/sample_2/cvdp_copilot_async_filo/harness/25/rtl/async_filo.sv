`timescale 1ns / 1ps

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
    input                         [DATA_WIDTH-1:0] w_data,   // Data input for push
    output logic [DATA_WIDTH-1:0] r_data,   // Data output for pop
    output logic                  r_empty,  // Empty flag
    output logic                  w_full    // Full flag
);

  // Address width
  localparam ADDR_WIDTH = $clog2(DEPTH);

  // Address pointers
  logic [ADDR_WIDTH:0] w_ptr;
  logic [ADDR_WIDTH:0] r_ptr;
  logic [ADDR_WIDTH:0] w_ptr_next;
  logic [ADDR_WIDTH:0] r_ptr_next;

  logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];
  wire [ADDR_WIDTH-1:0] w_addr;
  wire [ADDR_WIDTH-1:0] r_addr;

  logic w_full_d1;

  logic [ADDR_WIDTH:0] w_full_f1;
  logic [ADDR_WIDTH-1:0] w_count_bin;
  logic [ADDR_WIDTH-1:0] r_count_bin;

  // Initialize pointers
  assign w_ptr = (w_rst) ? 0 : w_ptr + 1;
  assign r_ptr = (r_rst) ? 0 : r_ptr + 1;

  // Initialize counts
  assign w_count_bin = (w_rst) ? 0 : w_count_bin + (push & ~w_full);
  assign r_count_bin = (r_rst) ? 0 : r_count_bin + (pop & ~r_empty);

  // Gray code conversion
  function automatic [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] bin);
    bin2gray = bin ^ (bin >> 1);
  endfunction

  function automatic [ADDR_WIDTH:0] gray2bin(input [ADDR_WIDTH:0] gray);
    gray2bin = gray;
    for (int i = 1; i <= ADDR_WIDTH; i++) gray2bin[i] = gray2bin[i] ^ gray2bin[i-1];
  endfunction

  // Full and empty flag logic
  assign w_full = (w_count_bin[ADDR_WIDTH] != w_ptr_next[ADDR_WIDTH]) &&
                  (w_count_bin[ADDR_WIDTH-1:0] == w_ptr_next[ADDR_WIDTH-1:0]);
  assign r_empty = (r_ptr_next == r_ptr);

  // Memory write logic
  always @(posedge w_clk) begin
    if (push && ~w_full) begin
      w_addr = w_count_bin;
      mem[w_addr] <= w_data;
    end
  end

  // Memory read logic
  always @(posedge r_clk) begin
    if (pop && ~r_empty) begin
      r_data <= mem[r_addr];
    end
  end

endmodule
