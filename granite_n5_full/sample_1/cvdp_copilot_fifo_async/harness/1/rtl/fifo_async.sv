module fifo_async #(parameter DATA_WIDTH = 8, parameter DEPTH = 16) (
  input wire w_clk,
  input wire w_rst,
  input wire w_inc,
  input wire [DATA_WIDTH-1:0] w_data,
  input wire r_clk,
  input wire r_rst,
  input wire r_inc,
  output reg w_full,
  output reg r_empty,
  output wire [DATA_WIDTH-1:0] r_data
);

  // Write pointer
  reg [log2(DEPTH)-1:0] wr_ptr;
  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      wr_ptr <= 0;
    end else if (w_inc) begin
      wr_ptr <= wr_ptr + 1;
    end
  end

  // Read pointer
  reg [log2(DEPTH)-1:0] rd_ptr;
  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      rd_ptr <= 0;
    end else if (r_inc) begin
      rd_ptr <= rd_ptr + 1;
    end
  end

  // Overflow flag
  wire full;
  assign full = (wr_ptr == rd_ptr) &&!w_inc;

  // Underflow flag
  wire empty;
  assign empty = (wr_ptr == rd_ptr+1) && r_inc;

  // Syncrhonize the clock domains to compare the pointers
  reg [log2(DEPTH)-1:0] wr_sync;
  reg [log2(DEPTH)-1:0] rd_sync;
  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      wr_sync <= 0;
    end else if (w_inc) begin
      wr_sync <= wr_sync + 1;
    end
  end

  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      rd_sync <= 0;
    end else if (r_inc) begin
      rd_sync <= rd_sync + 1;
    end
  end

  // Compare the pointers
  wire sync_equal = wr_sync == rd_sync;

  // Assign the output signals
  assign w_full = full;
  assign r_empty = empty;
  assign r_data = w_inc? w_data : 0;

endmodule