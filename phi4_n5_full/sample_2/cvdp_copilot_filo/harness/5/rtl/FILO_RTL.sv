module FILO_RTL #(
  parameter DATA_WIDTH = 8,
  parameter FILO_DEPTH  = 16
)(
  input  logic           clk,
  input  logic           reset,
  input  logic           push,
  input  logic           pop,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic           full,
  output logic           empty
);

  // Calculate pointer width (assumes FILO_DEPTH is a power of 2)
  localparam PTR_WIDTH = $clog2(FILO_DEPTH);

  // Memory array to store FILO data
  logic [DATA_WIDTH-1:0] mem [0:FILO_DEPTH-1];

  // Stack pointer: number of elements currently stored
  logic [PTR_WIDTH-1:0] top;

  // Full signal is asserted when the pointer equals FILO_DEPTH
  assign full  = (top == FILO_DEPTH);
  // Empty signal is asserted when the pointer is 0
  assign empty = (top == 0);

  // Sequential process for push/pop operations
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      top <= 0;
      // Clear the memory on reset
      integer i;
      for (i = 0; i < FILO_DEPTH; i = i + 1) begin
        mem[i] <= 0;
      end
    end
    else begin
      // Case 1: Both push and pop are asserted
      if (push && pop) begin
        if (empty) begin
          // Feedthrough: When the buffer is empty, pass data_in directly to data_out
          // without storing it in memory. The pointer remains unchanged.
          data_out <= data_in;
          // No memory update
        end
        else begin
          // Both push and pop are asserted and the buffer is not empty.
          // Perform push then pop: store data_in at the current top (overwriting the top element)
          // then leave the pointer unchanged, and output the pushed data.
          mem[top] <= data_in;
          top       <= top;  // pointer remains unchanged
          data_out  <= data_in;
        end
      end
      // Case 2: Only push is asserted
      else if (push && !pop) begin
        if (top < FILO_DEPTH) begin
          // Store data_in at the current top and increment the pointer.
          mem[top] <= data_in;
          top       <= top + 1;
          // data_out remains unchanged (no pop)
        end
      end
      // Case 3: Only pop is asserted
      else if (!push && pop) begin
        if (top > 0) begin
          // Decrement the pointer and output the data from the new top.
          top       <= top - 1;
          data_out  <= mem[top];
        end
      end
      // Case 4: No valid operation (neither push nor pop)
      else begin
        // Retain the previous state.
      end
    end
  end

endmodule