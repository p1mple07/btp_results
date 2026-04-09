module write_buffer_merge #(
  parameter INPUT_DATA_WIDTH  = 32,                   // Width of input data
  parameter INPUT_ADDR_WIDTH  = 16,                   // Width of input address
  parameter BUFFER_DEPTH      = 8,                    // Depth of the write buffer
  parameter OUTPUT_DATA_WIDTH = INPUT_DATA_WIDTH * BUFFER_DEPTH,  // Width of merged output data
  parameter OUTPUT_ADDR_WIDTH = INPUT_ADDR_WIDTH - $clog2(BUFFER_DEPTH)  // Width of merged output address
) (
  input  logic                         clk,           // Clock signal
  input  logic                         srst,          // Synchronous reset (active high)
  input  logic                         wr_en_in,      // Write enable input
  input  logic [INPUT_ADDR_WIDTH-1:0]  wr_addr_in,    // Write address input
  input  logic [INPUT_DATA_WIDTH-1:0]  wr_data_in,    // Write data input
  output logic                         wr_en_out,     // Write enable output
  output logic [OUTPUT_ADDR_WIDTH-1:0] wr_addr_out,   // Write address output
  output logic [OUTPUT_DATA_WIDTH-1:0] wr_data_out    // Write data output
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
          write_count <= '0';
        else
          write_count <= write_count + 1;
      end

endmodule