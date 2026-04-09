module sync_lifo(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
);
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
);
  input clock;
  input reset;
  input write_en;
  input read_en;
  input data_in;
  output empty;
  output full;
  output data_out;

  // Configuration parameters
  parameter FIFO_DEPTH = 2**ADDR_WIDTH;
  integer pointer = 0;

  // FIFO array
  array<int, DATA_WIDTH> fifo_FIFO = {0} * FIFO_DEPTH;

  // Initial block
  initial begin
    if (reset) begin
      pointer = 0;
      fifo_FIFO = {0};
      empty = 1;
      full = 0;
    end
  end

  // Write operation
  always @posedge clock begin
    if (write_en) begin
      if (pointer < FIFO_DEPTH) begin
        fifo_FIFO[pointer] = data_in;
        pointer = pointer + 1;
        if (pointer > FIFO_DEPTH) begin
          full = 1;
        end
      end
    end
  end

  // Read operation
  always @posedge clock begin
    if (read_en) begin
      if (pointer > 0) begin
        data_out = fifo_FIFO[pointer];
        pointer = pointer - 1;
        if (pointer < 0) begin
          empty = 1;
        end
      end
    end
  end
endmodule