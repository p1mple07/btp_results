module FILO_RTL #(
  parameter DATA_WIDTH = 8,
  parameter FILO_DEPTH = 16
)(
  input  logic                     clk,
  input  logic                     reset,
  input  logic                     push,
  input  logic                     pop,
  input  logic [DATA_WIDTH-1:0]    data_in,
  output logic [DATA_WIDTH-1:0]    data_out,
  output logic                     full,
  output logic                     empty
);

  // Calculate address width for the pointer based on FILO_DEPTH.
  localparam ADDR_WIDTH = $clog2(FILO_DEPTH);

  // Memory to store FILO data elements.
  reg [DATA_WIDTH-1:0] mem [0:FILO_DEPTH-1];

  // Stack pointer indicating the next free location.
  reg [ADDR_WIDTH-1:0] top;

  // Intermediate register used for simultaneous push & pop operations.
  reg [ADDR_WIDTH-1:0] temp_top;

  // Sequential process: operations occur on rising edge of clk or asynchronous reset.
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset: clear pointer and memory, and set status signals.
      top          <= 0;
      integer i;
      for (i = 0; i < FILO_DEPTH; i = i + 1) begin
        mem[i] <= '0;
      end
      full   <= 0;
      empty  <= 1;
      data_out <= '0;
    end
    else begin
      // Check for simultaneous push and pop.
      if (push && pop) begin
        if (top == 0) begin
          // Feedthrough case: FILO is empty.
          // Pass input data directly to output without storing it.
          data_out <= data_in;
          // Pointer remains unchanged.
        end
        else begin
          // When buffer is not empty, perform both push and pop.
          // The net effect is that data_in is pushed and then immediately popped,
          // so the stack pointer remains unchanged.
          temp_top <= top;              // Save current top index.
          mem[temp_top] <= data_in;     // Store data_in at current top.
          top <= temp_top + 1;          // Push: increment pointer.
          top <= temp_top;              // Pop: decrement pointer back to original.
          data_out <= data_in;          // Output the pushed data.
        end
      end
      // Only push operation.
      else if (push) begin
        if (top != (FILO_DEPTH-1)) begin
          mem[top] <= data_in;
          top <= top + 1;
        end
        // If full, do nothing.
      end
      // Only pop operation.
      else if (pop) begin
        if (top != 0) begin
          top <= top - 1;
          data_out <= mem[top];
        end
        // If empty, do nothing.
      end
    end
  end

  // Combinational assignments for status signals.
  assign full  = (top == FILO_DEPTH);
  assign empty = (top == 0);

endmodule