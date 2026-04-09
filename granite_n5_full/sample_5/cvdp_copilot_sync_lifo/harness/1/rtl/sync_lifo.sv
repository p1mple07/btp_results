module sync_lifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
)(
    input logic clock,
    input logic reset,
    input logic write_en,
    input logic read_en,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic empty,
    output logic full,
    output logic [DATA_WIDTH-1:0] data_out
);

  // Define FIFO memory
  logic [DATA_WIDTH-1:0] fifo[2**ADDR_WIDTH-1:0];
  logic [ADDR_WIDTH-1:0] head;
  logic [ADDR_WIDTH-1:0] tail;
  logic [ADDR_WIDTH-1:0] count;

  // Write operation
  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      head <= 0;
      tail <= 0;
      count <= 0;
    end else begin
      if (write_en &&!full) begin
        fifo[head] <= data_in;
        head <= head + 1;
        count <= count + 1;
      end
    end
  end

  // Read operation
  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      data_out <= 0;
    end else begin
      if (read_en &&!empty) begin
        data_out <= fifo[tail];
        tail <= tail + 1;
      end
    end
  end

  // Empty condition
  assign empty = (count == 0);

  // Full condition
  assign full = ((head - tail) == 2**ADDR_WIDTH);

endmodule