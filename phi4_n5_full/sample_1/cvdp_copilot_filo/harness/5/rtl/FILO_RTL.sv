module FILO_RTL #(
  parameter DATA_WIDTH = 8,
  parameter FILO_DEPTH  = 16
)(
  input  logic                  clk,
  input  logic                  reset,
  input  logic                  push,
  input  logic                  pop,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic                  full,
  output logic                  empty
);

  // Internal memory to store FILO data elements.
  // Memory indices: 0 to FILO_DEPTH-1.
  reg [DATA_WIDTH-1:0] mem [0:FILO_DEPTH-1];

  // Stack pointer: "top" indicates the next free location.
  // When top == 0, the buffer is empty.
  // When top == FILO_DEPTH, the buffer is full.
  // We use a pointer width sufficient to count from 0 to FILO_DEPTH.
  reg [$clog2(FILO_DEPTH+1)-1:0] top;

  // Registered output for data_out.
  reg [DATA_WIDTH-1:0] data_out_reg;

  //-------------------------------------------------------------------------
  // Main sequential process: Handles push, pop and the feedthrough case.
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      top            <= 0;
      // On reset, buffer is empty and not full.
      empty          <= 1;
      full           <= 0;
      data_out_reg   <= '0;
    end
    else begin
      // -----------------------------------------------------------------
      // Feedthrough: If the FILO is empty and both push and pop are high,
      // immediately pass data_in to data_out without storing it.
      // -----------------------------------------------------------------
      if (empty && push && pop) begin
        data_out_reg <= data_in;
        // Do not update memory or pointer.
        top <= top;
      end
      else begin
        // Use a local variable to compute the next pointer value.
        integer next_top = top;
        
        // -----------------------------------------------------------------
        // When both push and pop are asserted concurrently.
        // -----------------------------------------------------------------
        if (push && pop) begin
          // If buffer is not full and not empty, perform push-pop concurrently.
          if (!full && !empty) begin
            // Store new data at current top.
            mem[top] <= data_in;
            // Increment pointer for push...
            next_top = top + 1;
            // ...then decrement pointer for pop (net effect: pointer remains unchanged).
            next_top = next_top - 1;
            // Output the pushed data.
            data_out_reg <= data_in;
          end
          // If only push is allowed (buffer not full, but pop condition may fail).
          else if (!full) begin
            mem[top] <= data_in;
            next_top = top + 1;
            // No pop; data_out remains unchanged.
          end
          // If only pop is allowed (buffer not empty, but push is disallowed because full).
          else if (!empty) begin
            next_top = top - 1;
            // Read the data from memory at the location that will be popped.
            data_out_reg <= mem[top - 1];
          end
        end
        // -----------------------------------------------------------------
        // Only push is asserted.
        // -----------------------------------------------------------------
        else if (push) begin
          if (!full) begin
            mem[top] <= data_in;
            next_top = top + 1;
          end
          // If full, do nothing.
        end
        // -----------------------------------------------------------------
        // Only pop is asserted.
        // -----------------------------------------------------------------
        else if (pop) begin
          if (!empty) begin
            next_top = top - 1;
            data_out_reg <= mem[top - 1];
          end
          // If empty, do nothing.
        end

        // Update the pointer.
        top <= next_top;
        // Update status signals based on the new pointer value.
        empty <= (next_top == 0);
        full  <= (next_top == FILO_DEPTH);
      end
    end
  end

  //-------------------------------------------------------------------------
  // Drive the output port.
  //-------------------------------------------------------------------------
  always_comb begin
    data_out = data_out_reg;
  end

endmodule