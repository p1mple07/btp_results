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

  // Additional signals for output logic (BUFFER_DEPTH > 1)
  logic [OUTPUT_ADDR_WIDTH-1:0]         latched_addr;
  logic [OUTPUT_DATA_WIDTH-1:0]         latched_data;
  logic                                 output_valid;
  logic [1:0]                           delay_cnt;

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
        else if (wr_en_in && (write_count == 0))
          base_addr <= wr_addr_in[INPUT_ADDR_WIDTH-1: $clog2(BUFFER_DEPTH)];
        // Else retain base_addr
      end

      // Merged data logic: Concatenates incoming data into the buffer
      always_ff @(posedge clk) begin
        if (srst)
          merged_data <= '0;
        else if (wr_en_in)
          merged_data <= {wr_data_in, merged_data[OUTPUT_DATA_WIDTH-INPUT_DATA_WIDTH-1:0]};
        // Else retain merged_data
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

      // Output logic for BUFFER_DEPTH > 1: 2-cycle latency
      always_ff @(posedge clk) begin
        if (srst) begin
          delay_cnt        <= 2'b11;
          output_valid     <= 0;
          wr_en_out        <= 0;
          wr_addr_out      <= '0;
          wr_data_out      <= '0;
          latched_addr     <= '0;
          latched_data     <= '0;
        end else begin
          if (write_complete) begin
            latched_addr  <= base_addr;
            latched_data  <= merged_data;
            output_valid  <= 1;
            delay_cnt     <= 2; // Start delay counter at 2 (for 2-cycle latency)
          end
          if (output_valid) begin
            if (delay_cnt != 0)
              delay_cnt <= delay_cnt - 1;
            else begin
              wr_addr_out <= latched_addr;
              wr_data_out <= latched_data;
              wr_en_out   <= 1'b1;
              output_valid <= 0; // Clear valid after output pulse
            end
          end else begin
            // Retain latched outputs until a new valid output occurs
            wr_addr_out <= latched_addr;
            wr_data_out <= latched_data;
            wr_en_out   <= 0;
          end
        end
      end

    end else begin

      // Passthrough logic for BUFFER_DEPTH = 1: 1-cycle latency
      always_ff @(posedge clk) begin
        if (srst) begin
          wr_en_out    <= 0;
          wr_addr_out  <= '0;
          wr_data_out  <= '0;
        end else begin
          wr_en_out    <= wr_en_in;
          wr_addr_out  <= wr_addr_in;
          wr_data_out  <= wr_data_in;
        end
      end

    end
  endgenerate

endmodule