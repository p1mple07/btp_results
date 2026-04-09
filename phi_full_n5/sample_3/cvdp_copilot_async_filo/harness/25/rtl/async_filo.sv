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

  // Memory
  logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];

  // Gray code conversion
  function automatic [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] bin);
    bin2gray = bin ^ (bin >> 1);
  endfunction

  function automatic [ADDR_WIDTH:0] gray2bin(input [ADDR_WIDTH:0] gray);
    gray2bin = gray;
    for (int i = 1; i <= ADDR_WIDTH; i++) gray2bin[i] = gray2bin[i] ^ gray2bin[i-1];
  endfunction

  // Counter
  logic [ADDR_WIDTH:0] w_count_bin, r_count_bin;

  // Reset
  assign w_full = 0;
  assign r_empty = 1;

  // Pointers
  always @(posedge w_clk) begin
    if (w_rst) begin
      w_ptr <= 0;
      r_ptr <= 0;
      w_count_bin <= 0;
    end else begin
      w_ptr <= w_ptr + 1;
      r_ptr <= r_ptr + 1;
      w_count_bin <= w_count_bin + (push & ~w_full);
    end
  end

  always @(posedge r_clk) begin
    if (r_rst) begin
      w_count_bin <= 0;
      r_ptr <= 0;
    end else begin
      w_count_bin <= r_count_bin + (pop & ~r_empty);
      r_ptr <= r_ptr + 1;
    end
  end

  // Write operations
  always @(posedge w_clk) begin
    if (push && !w_full) begin
      mem[w_count_bin[ADDR_WIDTH-1:0]] <= w_data;
      w_count_bin <= w_count_bin + 1;
    end
    w_full <= (w_count_bin[ADDR_WIDTH] != r_ptr);
  end

  // Read operations
  always @(posedge r_clk) begin
    if (pop && r_ptr == w_count_bin[ADDR_WIDTH]) begin
      r_data <= mem[r_count_bin[ADDR_WIDTH-1:0]];
      r_count_bin <= r_count_bin + 1;
      r_empty <= 0;
    end
  end

endmodule
