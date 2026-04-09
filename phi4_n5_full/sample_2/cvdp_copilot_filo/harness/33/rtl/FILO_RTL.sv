module FILO_RTL #(
    parameter DATA_WIDTH = 8,  // Width of the data entries
    parameter FILO_DEPTH = 16  // Depth of the FILO buffer
) (
    input  wire                  clk,       // Clock signal
    input  wire                  reset,     // Asynchronous reset signal
    input  wire                  push,      // Push control signal
    input  wire                  pop,       // Pop control signal
    input  wire [DATA_WIDTH-1:0] data_in,   // Data input
    output reg  [DATA_WIDTH-1:0] data_out,  // Data output
    output reg                   full,      // Full status signal
    output reg                   empty      // Empty status signal
);

  reg [DATA_WIDTH-1:0] memory[FILO_DEPTH-1:0];  
  reg [$clog2(FILO_DEPTH):0] top;  
 
  reg feedthrough_valid;
  reg [DATA_WIDTH-1:0] feedthrough_data;

 
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      top             <= 0;
      empty           <= 1;
      full            <= 0;
      feedthrough_valid <= 0;
      data_out        <= 0;  
    end else begin
    
      // Special case: push and pop simultaneously on an empty buffer (feedthrough)
      if (push && pop && empty) begin
        data_out         <= data_in; 
        feedthrough_data <= data_in;
        feedthrough_valid<= 1;
      end else begin
      
        // Push operation: store data at current top pointer and increment
        if (push && !full) begin
          memory[top]         <= data_in;  
          top                 <= top + 1;  
          feedthrough_valid   <= 0;
        end

        // Pop operation: if valid feedthrough, use feedthrough data; otherwise, decrement top pointer and output memory value
        if (pop && !empty) begin
          if (feedthrough_valid) begin
            data_out         <= feedthrough_data;  
            feedthrough_valid<= 0;
          end else begin
            top             <= top - 1;   // Decrement the stack pointer for pop operation
            data_out        <= memory[top];  // Read from updated pointer location
          end
        end
      end

      // Update status flags
      empty <= (top == 0);
      full  <= (top == FILO_DEPTH);  
    end
  end
endmodule