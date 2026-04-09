module fifo_async #(parameter DATA_WIDTH = 8, parameter DEPTH = 16) (
  input wire w_clk,
  input wire w_rst,
  input wire w_inc,
  input wire [DATA_WIDTH-1:0] w_data,
  input wire r_clk,
  input wire r_rst,
  input wire r_inc,
  output logic w_full,
  output logic r_empty,
  output logic [DATA_WIDTH-1:0] r_data
);

  // Write and read pointers
  reg [log2up(DEPTH)-1:0] wptr;
  reg [log2up(DEPTH)-1:0] rptr;

  // Overflow flag
  wire overflow;

  // Counter for tracking the write and read positions
  always @(posedge w_clk or posedge w_rst) begin
    if (w_rst)
      wptr <= 0;
    else if (w_inc &&!overflow)
      wptr <= (wptr == DEPTH-1)? 0 : wptr + 1;
  end

  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst)
      rptr <= 0;
    else if (r_inc)
      rptr <= (rptr == DEPTH-1)? 0 : rptr + 1;
  end

  // Empty and full flags
  assign w_full = (wptr == rptr);
  assign r_empty = (wptr == rptr);

  // Read data
  always @(posedge r_clk or posedge r_rst) begin
    if (r_rst)
      r_data <= 0;
    else if (!r_empty)
      r_data <= w_data;
  end

endmodule