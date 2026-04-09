module sync_lifo #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 3
)(
  input  logic        clock,
  input  logic        reset,
  input  logic        write_en,
  input  logic        read_en,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic        empty,
  output logic        full,
  output logic [DATA_WIDTH-1:0] data_out
);

  // Calculate the depth of the LIFO based on ADDR_WIDTH.
  localparam integer DEPTH = (1 << ADDR_WIDTH);

  // Memory array for LIFO storage.
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Stack pointer indicating the number of elements in the LIFO.
  // When sp == 0, the LIFO is empty.
  // When sp == DEPTH, the LIFO is full.
  logic [ADDR_WIDTH-1:0] sp;

  // Combinational assignments for empty and full signals.
  assign empty = (sp == 0);
  assign full  = (sp == DEPTH);

  // Synchronous process for LIFO operations.
  always_ff @(posedge clock) begin
    if (reset) begin
      sp        <= 0;
      data_out  <= '0;
    end else begin
      // Write operation: push data if not full.
      if (write_en && !full) begin
        mem[sp] <= data_in;
        sp      <= sp + 1;
      end
      // Read operation: pop data if not empty.
      else if (read_en && !empty) begin
        data_out <= mem[sp - 1];
        sp       <= sp - 1;
      end
    end
  end

endmodule