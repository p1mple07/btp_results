module sync_lifo #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 3
) (
  input  logic         clock,
  input  logic         reset,
  input  logic         write_en,
  input  logic         read_en,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic         empty,
  output logic         full,
  output logic [DATA_WIDTH-1:0] data_out
);

  // Calculate the depth of the LIFO based on ADDR_WIDTH.
  localparam int DEPTH = 2**ADDR_WIDTH;

  // Memory array to store data.
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Pointer indicating the next free position (top of the stack).
  reg [ADDR_WIDTH-1:0] top_ptr;

  // Register to hold the data output.
  reg [DATA_WIDTH-1:0] data_out_reg;

  // Combinational assignments for empty and full flags.
  assign empty = (top_ptr == 0);
  assign full  = (top_ptr == DEPTH-1);

  // Synchronous process for LIFO operations.
  always_ff @(posedge clock) begin
    if (reset) begin
      // On reset, clear the pointer and output.
      top_ptr            <= 0;
      data_out_reg       <= '0;
      // Clear the memory array.
      integer i;
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] <= '0;
      end
    end
    else begin
      // Read operation: if read_en is asserted and LIFO is not empty,
      // pop the top element and update the pointer.
      if (read_en && !empty) begin
        data_out_reg <= mem[top_ptr - 1];
        top_ptr      <= top_ptr - 1;
      end

      // Write operation: if write_en is asserted and LIFO is not full,
      // push new data into the memory and update the pointer.
      if (write_en && !full) begin
        mem[top_ptr] <= data_in;
        top_ptr      <= top_ptr + 1;
      end
    end
  end

  // Drive the output data.
  always_comb begin
    data_out = data_out_reg;
  end

endmodule