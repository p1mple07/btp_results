module fifo_async #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH       = 16
)(
  // Clock and Reset signals
  input wire w_clk,
  input wire w_rst,
  input wire r_clk,
  input wire r_rst,
  
  // Write Data Interface
  input wire w_inc,
  input wire [DATA_WIDTH-1:0] w_data,
  
  // Read Data Interface
  input wire r_inc,
  output logic r_empty,
  output logic r_full,
  output logic [DATA_WIDTH-1:0] r_data
);

  // Gray Counters for Write and Read Pointers
  logic [log2up(DEPTH)-1:0] wptr;
  logic [log2up(DEPTH)-1:0] rptr;

  // Synchronize Write and Read Clock Domains
  always_ff @(posedge w_clk or posedge w_rst) begin
    if (w_rst) begin
      wptr <= 0;
    end else if (w_inc) begin
      wptr <= wptr + 1;
    end
  end

  always_ff @(posedge r_clk or posedge r_rst) begin
    if (r_rst) begin
      rptr <= 0;
    end else if (r_inc) begin
      rptr <= rptr + 1;
    end
  end

  // Compare Write and Read Pointers
  assign r_empty = (wptr == rptr);
  assign r_full  = ((wptr[log2up(DEPTH)-1:0] ^ rptr[log2up(DEPTH)-1:0]) & (|wptr)) |
                      ((~wptr[log2up(DEPTH)-1:0]) & rptr[log2up(DEPTH)-1:0]);

  // Pass Write Pointer to Read Clock Domain
  logic [log2up(DEPTH)-1:0] wptr_sync;
  always_ff @(posedge r_clk) begin
    wptr_sync <= wptr;
  end

  // Pass Read Pointer to Write Clock Domain
  logic [log2up(DEPTH)-1:0] rptr_sync;
  always_ff @(posedge w_clk) begin
    rptr_sync <= rptr;
  end

  // Assign Output Data based on Read Pointer
  generate
    if (DEPTH > 1) begin : gen_multi_cycle_output
      assign r_data = r_empty? 'x : fifo_mem[rptr];
    end else begin : gen_single_cycle_output
      assign r_data = r_empty? 'x : wptr_sync;
    end
  endgenerate

endmodule