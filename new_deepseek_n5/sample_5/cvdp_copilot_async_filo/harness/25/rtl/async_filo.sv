`timescale 1ns / 1ps

module async_filo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 8
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

  always @(posedge w_clk) begin
    w_ptr <= r_ptr;
  end

  always @(posedge w_clk) begin
    w_ptr <= w_ptr + 1;
  end

  always @(*) begin
    if (push) w_full_d1 = 1;
  end

  logic [ADDR_WIDTH+1:0] w_full_f1;
  always @(posedge w_clk) begin
    w_full_f1 <= w_count_next_bin;
  end

  always @(posedge w_rst) begin
    w_ptr <= 0;
  end

  always @(posedge w_clk) begin
    if (push && !w_full) w_addr = w_addr + 1;
  end

  always @(posedge w_clk) begin
    if (push && !w_full) mem[w_addr] <= w_data;
  end

  assign r_data = mem[r_addr];

  logic [ADDR_WIDTH:0] wq1_rptr, wq2_rptr;
  logic [ADDR_WIDTH:0] rq1_wptr, rq2_wptr;

  always @(posedge w_clk, posedge w_rst) begin
    if (w_rst) begin
      wq1_rptr <= 0;
      wq2_rptr <= 0;
    end else begin
      wq1_rptr <= r_ptr;
      wq2_rptr <= wq1_rptr;
    end
  end

  always @(posedge r_clk, posedge r_rst) begin
    if (r_rst) begin
      rq1_wptr <= 0;
      rq2_wptr <= 0;
    end else begin
      rq1_wptr <= w_ptr;
      rq2_wptr <= rq1_wptr;
    end
  end

  always @(posedge w_clk) begin
    if (push && !w_full) w_addr = w_addr + 1;
  end

  function automatic [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] bin);
    bin2gray = bin ^ (bin >> 1);
  endfunction

  logic [ADDR_WIDTH:0] w_count_bin, r_count_bin;
  wire [ADDR_WIDTH:0] w_count_next_bin, r_count_next_bin;
  wire [ADDR_WIDTH:0] wq2_rptr_bin;

  always @(posedge w_clk, posedge w_rst) begin
    if (w_rst) begin
      w_count_bin <= 0;
      w_ptr       <= 0;
    end else begin
      w_count_bin <= w_count_next_bin;
      w_ptr       <= w_ptr_next;
    end
  end

  assign w_count_next_bin = w_count_bin + ({(ADDR_WIDTH+1){push}} & ~{(ADDR_WIDTH+1){w_full}});
  assign w_ptr_next = bin2gray(w_count_next_bin);
  assign wq2_rptr_bin = w_ptr_next;

  always @(posedge r_clk, posedge r_rst) begin
    if (r_rst) begin
      r_count_bin <= 0;
      r_ptr       <= 0;
    end else begin
      r_count_bin <= r_count_next_bin;
      r_ptr       <= r_ptr_next;
    end
  end

  assign r_count_next_bin = r_count_bin + ({(ADDR_WIDTH+1){pop}} & ~{(ADDR_WIDTH+1){r_empty}});
  assign r_ptr_next = bin2gray(r_count_next_bin);

  assign w_addr = w_count_bin[ADDR_WIDTH-1:0];
  assign r_addr = r_count_bin[ADDR_WIDTH-1:0];

  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_empty <= 1;
    end else begin
      r_empty <= (r_ptr_next == rq2_wptr);
    end
  end

  always @(posedge w_clk or posedge w_rst) begin
    case (w_ptr)
      5'b00000: w_full_d1 <= 1;
      5'b11111: w_full_d1 <= 0;
      default:  w_full_d1 <= 2;
    endcase
  end