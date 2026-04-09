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
  logic [ADDR_WIDTH:0] w_ptr, w_ptr_next;
  logic [ADDR_WIDTH:0] r_ptr, r_ptr_next;

  logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];
  wire [ADDR_WIDTH-1:0] w_addr, r_addr;

  logic w_full;

  logic [ADDR_WIDTH:0] w_full_f1;

  // Initialize pointers and flags
  always @ (posedge w_clk) begin
    if (w_rst) begin
      w_ptr <= 0;
      w_ptr_next <= 0;
      w_full <= 0;
      r_ptr <= 0;
      r_ptr_next <= 0;
    end else begin
      w_ptr <= w_ptr_next;
      w_ptr_next <= w_ptr + 1;
      w_full <= (w_count_next_bin[ADDR_WIDTH] != wq2_rptr_bin[ADDR_WIDTH]) &&
                  (w_count_next_bin[ADDR_WIDTH-1:0] == wq2_rptr_bin[ADDR_WIDTH-1:0]);
    end
  end

  always @ (posedge w_clk) begin
    if (push && !w_full) begin
      w_addr = w_addr + 1;
      mem[w_addr] <= w_data;
    end
  end

  always @ (posedge r_clk) begin
    if (r_rst) begin
      r_ptr <= 0;
      r_ptr_next <= 0;
    end else begin
      r_ptr <= r_ptr_next;
      r_ptr_next <= r_ptr + 1;
    end
  end

  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      r_empty <= 1;
    end else begin
      r_empty <= (r_ptr_next == rq2_wptr);
    end
  end

  always @(posedge w_clk) begin
    case (w_ptr)
      5'b00000: w_full <= 1;
      5'b11111: w_full <= 0;
      default: w_full <= 2;
    endcase
  end

endmodule
