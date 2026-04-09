module sync_lifo #(
 parameter int DATA_WIDTH = 8,
 parameter int ADDR_WIDTH = 3
) (
  input logic             clock,
  input logic             reset,

  input logic             write_en,
  input logic [DATA_WIDTH-1:0] data_in,

  output logic            empty,
  output logic            full,
  output logic [DATA_WIDTH-1:0] data_out,

  input logic             read_en
);

  localparam int ADDR_MAX = 2**ADDR_WIDTH;
  localparam int DEPTH = ADDR_MAX + 1;
  logic [DATA_WIDTH-1:0] mem[DEPTH];
  logic [ADDR_WIDTH-1:0] addr;
  logic [DATA_WIDTH-1:0] head;
  logic [DATA_WIDTH-1:0] tail;

  assign empty = (head == tail);
  assign full = (addr == ADDR_MAX);

  always_ff @(posedge clock) begin
    if (reset) begin
      head <= 0;
      tail <= 0;
      addr <= 0;
    end else begin
      if (write_en &&!full) begin
        mem[addr] <= data_in;
        addr <= addr + 1;
        head <= head + 1;
      end

      if (read_en &&!empty) begin
        data_out <= mem[tail];
        tail <= tail + 1;
      end
    end
  end

endmodule