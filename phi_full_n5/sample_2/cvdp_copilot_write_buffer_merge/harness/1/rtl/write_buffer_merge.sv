module write_buffer_merge #(
  parameter INPUT_DATA_WIDTH  = 32,                                     // Width of input data
  parameter INPUT_ADDR_WIDTH  = 16,                                     // Width of input address
  parameter BUFFER_DEPTH      = 8,                                      // Depth of the write buffer
  parameter OUTPUT_DATA_WIDTH = INPUT_DATA_WIDTH * BUFFER_DEPTH,        // Width of merged output data
  parameter OUTPUT_ADDR_WIDTH = INPUT_ADDR_WIDTH - $clog2(BUFFER_DEPTH) // Width of merged output address
) (
  input  logic                         clk,          // Clock signal
  input  logic                         srst,         // Synchronous reset (active high)
  input  logic                         wr_en_in,     // Write enable input
  input  logic [INPUT_ADDR_WIDTH-1:0]  wr_addr_in,   // Write address input
  input  logic [INPUT_DATA_WIDTH-1:0]  wr_data_in,   // Write data input
  output logic                         wr_en_out,    // Write enable output
  output logic [OUTPUT_ADDR_WIDTH-1:0] wr_addr_out,  // Write address output
  output logic [OUTPUT_DATA_WIDTH-1:0] wr_data_out   // Write data output
);

  // Internal signals for buffer tracking and management
  logic [$clog2(BUFFER_DEPTH)-1:0]      write_count;     // Counter for the number of writes in the buffer
  logic [OUTPUT_ADDR_WIDTH-1:0]         base_addr;       // Base address for the merged writes
  logic [OUTPUT_DATA_WIDTH-1:0]         merged_data;     // Buffer to hold merged data
  logic                                 write_complete;  // Signal to indicate that the buffer is full and ready to output

  generate
    if (BUFFER_DEPTH > 1) begin
      // Write count logic: Counts the number of writes in the buffer
      always_ff @(posedge clk) begin
        if (srst) 
          write_count <= '0;
        else if (wr_en_in)
          write_count <= write_count + 1;  // Increment count on write enable
      end

      // Base address logic: Captures the address of the first write in the buffer
      always_ff @(posedge clk) begin
        if (srst)
          base_addr <= '0;
        else if (write_count == 0)
          base_addr <= wr_addr_in; // Capture base address on first write
      end

      // Merged data logic: Concatenates incoming data into the buffer
      always_ff @(posedge clk) begin
        if (srst)
          merged_data <= '0;
        else if (wr_en_in)
          merged_data <= {merged_data[{BUFFER_DEPTH-1}:0], wr_data_in}; // Shift existing data and append new data
      end

      // Write completion logic: Indicates when the buffer is full
      always_ff @(posedge clk) begin
        if (srst)
          write_complete <= 1'b0;
        else if ((write_count == (BUFFER_DEPTH - 1)) && wr_en_in)
          write_complete <= 1'b1;  // Assert completion when buffer is full
        else
          write_complete <= 1'b0;
      end

      // Output logic for BUFFER_DEPTH > 1
      always_ff @(posedge clk) begin
        if (wr_en_in && write_complete) begin
          wr_en_out <= 1; // Set on the next clock cycle
          wr_addr_out <= base_addr;
          wr_data_out <= merged_data;
          write_complete <= 0; // Reset completion signal after output
        end
        wr_en_out <= wr_en_in; // Default to input enable on next clock cycle
        wr_addr_out <= base_addr; // Maintain base address until next valid output
        wr_data_out <= merged_data; // Maintain merged data until next valid output
      end

    end else begin

      // Passthrough output logic for BUFFER_DEPTH = 1
      always_ff @(posedge clk) begin
        if (wr_en_in && (write_count == 1)) begin
          wr_en_out <= 1; // Set on the next clock cycle
          wr_addr_out <= wr_addr_in;
          wr_data_out <= wr_data_in;
          write_count <= 2; // Increase write count by 1 (latency of 1 clock cycle)
        end
        wr_en_out <= wr_en_in; // Default to input enable on next clock cycle
        wr_addr_out <= wr_addr_in;
        wr_data_out <= wr_data_in;
      end

    end
  endgenerate

endmodule
