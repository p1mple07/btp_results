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
          base_addr <= wr_addr_in[INPUT_ADDR_WIDTH-1: $clog2(BUFFER_DEPTH)];
      end

      // Merged data logic: Concatenates incoming data into the buffer
      // On each write, shift the current merged_data right by INPUT_DATA_WIDTH bits and prepend the new data.
      always_ff @(posedge clk) begin
        if (srst)
          merged_data <= '0;
        else if (wr_en_in)
          merged_data <= {wr_data_in, merged_data[OUTPUT_DATA_WIDTH-INPUT_DATA_WIDTH-1:0]};
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

      // Output pipeline registers for BUFFER_DEPTH > 1:
      // Latch the merged output values when the buffer is full and delay for 2 clock cycles.
      reg [OUTPUT_ADDR_WIDTH-1:0] latch_addr;
      reg [OUTPUT_DATA_WIDTH-1:0] latch_data;
      reg [1:0] delay_counter;

      always_ff @(posedge clk) begin
        if (srst) begin
          latch_addr    <= '0;
          latch_data    <= '0;
          delay_counter <= 0;
        end else if (write_complete) begin
          latch_addr    <= base_addr;
          latch_data    <= merged_data;
          delay_counter <= 2; // Initiate a 2-cycle delay
        end else if (delay_counter != 0)
          delay_counter <= delay_counter - 1;
      end

      // Final output generation:
      // Drive outputs only on the cycle when delay_counter equals 1, generating a one-cycle pulse for wr_en_out.
      always_ff @(posedge clk) begin
        if (srst) begin
          wr_addr_out <= '0;
          wr_data_out <= '0;
          wr_en_out   <= 0;
        end else if (delay_counter == 1) begin
          wr_addr_out <= latch_addr;
          wr_data_out <= latch_data;
          wr_en_out   <= 1;
        end else begin
          wr_en_out <= 0;
        end
      end

    end else begin

      // Pass-through logic for BUFFER_DEPTH = 1:
      // Implement a one-cycle delay so that inputs are forwarded directly to outputs after one clock cycle.
      reg [INPUT_ADDR_WIDTH-1:0] pass_addr_reg;
      reg [INPUT_DATA_WIDTH-1:0] pass_data_reg;
      reg pass_en_reg;

      always_ff @(posedge clk) begin
        if (srst) begin
          pass_addr_reg <= '0;
          pass_data_reg <= '0;
          pass_en_reg   <= 0;
        end else begin
          pass_addr_reg <= wr_addr_in;
          pass_data_reg <= wr_data_in;
          pass_en_reg   <= wr_en_in;
        end
      end

      always_ff @(posedge clk) begin
        if (srst) begin
          wr_addr_out <= '0;
          wr_data_out <= '0;
          wr_en_out   <= 0;
        end else begin
          wr_addr_out <= pass_addr_reg;
          wr_data_out <= pass_data_reg;
          wr_en_out   <= pass_en_reg;
        end
      end

    end
  endgenerate

endmodule