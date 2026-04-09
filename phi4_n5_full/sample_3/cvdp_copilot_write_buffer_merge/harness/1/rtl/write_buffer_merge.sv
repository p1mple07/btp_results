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
        else if (wr_en_in && (write_count == 0))
          // Capture the most significant bits of wr_addr_in by stripping off the LSBs
          base_addr <= wr_addr_in[INPUT_ADDR_WIDTH-1:$clog2(BUFFER_DEPTH)];
      end

      // Merged data logic: Concatenates incoming data into the buffer
      always_ff @(posedge clk) begin
        if (srst)
          merged_data <= '0';
        else if (wr_en_in)
          // Shift existing data right by INPUT_DATA_WIDTH bits and prepend new data
          merged_data <= {wr_data_in, merged_data[OUTPUT_DATA_WIDTH-INPUT_DATA_WIDTH-1:0]};
      end

      // Write completion logic: Indicates when the buffer is full and ready to output
      always_ff @(posedge clk) begin
        if (srst)
          write_complete <= 1'b0;
        else if ((write_count == (BUFFER_DEPTH - 1)) && wr_en_in)
          write_complete <= 1'b1;  // Assert completion when buffer is full
        else
          write_complete <= 1'b0;
      end

      // Output logic: Generate outputs with 2 clock cycles latency using a two-stage pipeline
      logic [OUTPUT_ADDR_WIDTH-1:0] out_addr_stage1, out_addr_stage2;
      logic [OUTPUT_DATA_WIDTH-1:0] out_data_stage1, out_data_stage2;
      logic stage_valid;

      always_ff @(posedge clk) begin
        if (srst) begin
          stage_valid      <= 1'b0;
          out_addr_stage1  <= '0;
          out_data_stage1  <= '0;
          out_addr_stage2  <= '0;
          out_data_stage2  <= '0;
          wr_en_out        <= 1'b0;
          wr_addr_out      <= '0;
          wr_data_out      <= '0;
        end else begin
          // Latch outputs when the buffer becomes full
          if (write_complete) begin
            out_addr_stage1 <= base_addr;
            out_data_stage1 <= merged_data;
            stage_valid     <= 1'b1;
          end
          // Second stage: update outputs after one pipeline stage
          if (stage_valid) begin
            out_addr_stage2 <= out_addr_stage1;
            out_data_stage2 <= out_data_stage1;
            wr_en_out       <= 1'b1;
            wr_addr_out     <= out_addr_stage2;
            wr_data_out     <= out_data_stage2;
            stage_valid     <= 1'b0;
          end else begin
            wr_en_out <= 1'b0;
          end
        end
      end

    end else begin
      // Passthrough logic for BUFFER_DEPTH = 1: 1 clock cycle latency
      logic [INPUT_ADDR_WIDTH-1:0] addr_reg;
      logic [INPUT_DATA_WIDTH-1:0] data_reg;
      logic en_reg;

      always_ff @(posedge clk) begin
        if (srst) begin
          en_reg      <= 1'b0;
          addr_reg    <= '0;
          data_reg    <= '0;
          wr_en_out   <= 1'b0;
          wr_addr_out <= '0;
          wr_data_out <= '0;
        end else begin
          // Latch the inputs for one cycle
          en_reg     <= wr_en_in;
          addr_reg   <= wr_addr_in;
          data_reg   <= wr_data_in;
          wr_en_out  <= en_reg;
          wr_addr_out<= addr_reg;
          wr_data_out<= data_reg;
        end
      end
    end
  endgenerate

endmodule