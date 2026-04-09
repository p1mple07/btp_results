module fifo_async #(
  parameter int unsigned DATA_WIDTH = 8,
  parameter int unsigned DEPTH       = 4
) (
  // Write side
  input  logic        w_clk,
  input  logic        w_rst,
  input  logic        w_inc,
  input  logic [DATA_WIDTH-1:0] w_data,

  // Read side
  input  logic        r_clk,
  input  logic        r_rst,
  input  logic        r_inc,
  output logic [DATA_WIDTH-1:0] r_data,

  // Status signals
  output logic        w_full,
  output logic        r_empty
);

  // Write/Read pointers
  logic [log2ceil(DEPTH)-1:0] wr_ptr;
  logic [log2ceil(DEPTH)-1:0] rd_ptr;

  //... (rest of the code goes here)
  // Ensure to include the entire solution code provided in the original snippet
  //...

endmodule