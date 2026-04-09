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
  logic write_complete;                  // Signal to indicate that the buffer is full and ready to output
  logic [OUTPUT_DATA_WIDTH-1:0]         data_out_reg;    // Register for output data

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
        else if (wr_addr_in) // Only capture address if write is valid
          base_addr <= (wr_addr_in >> ($INPUT_ADDR_WIDTH - $clog2(BUFFER_DEPTH)));  // Mask higher bits
      end

      // Merged data logic: Concatenates incoming data into the buffer
      always_ff @(posedge clk) begin
        if (srst)
          merged_data <= '0;
        else if (wr_en_in)
          merged_data <= (merged_data << INPUT_DATA_WIDTH) | wr_data_in;  // Shift left and append new data
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

      // Output logic for buffer depth > 1
      always @(posedge clk) begin
        if (write_complete && !srst) begin
          // Output latches with 2-cycle latency
          data_out_reg <= merged_data;
        end
        // Only update outputs when write_complete is high for two clocks
        if (data_out_reg & (~write_complete)) begin
          wr_en_out <= 1'b0;
          wr_addr_out <= base_addr;
          wr_data_out <= data_out_reg;
        end
      end
    end else begin
      // Pass-through logic for buffer depth = 1
      always @(posedge clk) begin
        if (srst)
          wr_en_out <= 1'b0;
          wr_addr_out <= 0;
          wr_data_out <= 0;
        else
          wr_en_out <= wr_en_in;
          wr_addr_out <= wr_addr_in;
          wr_data_out <= wr_data_in;
        end
      end
    end
  endgenerate

endmodule