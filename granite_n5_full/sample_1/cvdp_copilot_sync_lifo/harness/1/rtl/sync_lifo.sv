module sync_lifo #(
  parameter int unsigned DATA_WIDTH = 8,
  parameter int unsigned ADDR_WIDTH = 3
) (
  input  logic                clock,
  input  logic                reset,
  input  logic                write_en,
  input  logic                read_en,
  input  [DATA_WIDTH-1:0]  data_in,
  output logic                empty,
  output logic                full,
  output [DATA_WIDTH-1:0]  data_out
);

  // Define the internal storage array
  logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];
  logic [$clog2(2**ADDR_WIDTH)-1:0] head;
  logic [$clog2(2**ADDR_WIDTH)-1:0] tail;
  assign empty = (head == tail);
  assign full = ((head+1)%(2**ADDR_WIDTH) == tail);

  // Implement the write operation
  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      head <= 0;
      tail <= 0;
    end else if (write_en &&!full) begin
      mem[tail] <= data_in;
      tail <= tail + 1;
    end
  end

  // Implement the read operation
  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      head <= 0;
      tail <= 0;
    end else if (read_en &&!empty) begin
      data_out <= mem[head];
      head <= head + 1;
    end
  end

endmodule