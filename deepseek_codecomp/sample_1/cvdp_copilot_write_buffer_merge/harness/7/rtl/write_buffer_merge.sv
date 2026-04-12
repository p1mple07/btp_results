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

  logic [$clog2(BUFFER_DEPTH)-1:0]      write_count;
  logic [OUTPUT_ADDR_WIDTH-1:0]         base_addr;
  logic [OUTPUT_DATA_WIDTH-1:0]         merged_data;
  logic                                 write_complete;

  generate
    if (BUFFER_DEPTH > 1) begin
      always_ff @(posedge clk) begin
        if (srst) 
          write_count <= '0;
        else if (wr_en_in)
          write_count <= write_count + 1;
      end

      always_ff @(posedge clk) begin
        if (srst)
          base_addr <= '0;
        else if ((write_count == 0) && wr_en_in)
          base_addr <= wr_addr_in[INPUT_ADDR_WIDTH-1:$clog2(BUFFER_DEPTH)];
      end

      always_ff @(posedge clk) begin
        if (srst)
          merged_data <= '0;
        else if (wr_en_in)
          merged_data <= {wr_data_in, merged_data[OUTPUT_DATA_WIDTH-1:INPUT_DATA_WIDTH]};
      end

      always_ff @(posedge clk) begin
        if (srst)
          write_complete <= 1'b0;
        else if ((write_count == (BUFFER_DEPTH - 1)) && wr_en_in)
          write_complete <= 1'b1;
        else
          write_complete <= 1'b0;
      end

      always_ff @(posedge clk) begin
        if (srst)
          wr_en_out <= 1'b0;
        else
          wr_en_out <= write_complete;
      end

      always_ff @(posedge clk) begin
        if (srst)
          wr_addr_out <= '0;
        else if (write_complete)
          wr_addr_out <= base_addr;
      end

      always_ff @(posedge clk) begin
        if (srst)
          wr_data_out <= '0;
        else if (write_complete)
          wr_data_out <= merged_data;
      end
    end else begin
      always_ff @(posedge clk) begin
        if (srst)
          wr_en_out <= 1'b0;
        else
          wr_en_out <= wr_en_in;
      end

      always_ff @(posedge clk) begin
        if (srst)
          wr_addr_out <= '0;
        else
          wr_addr_out <= wr_addr_in;
      end

      always_ff @(posedge clk) begin
        if (srst)
          wr_data_out <= '0;
        else
          wr_data_out <= wr_data_in;
      end
    end
  endgenerate

endmodule