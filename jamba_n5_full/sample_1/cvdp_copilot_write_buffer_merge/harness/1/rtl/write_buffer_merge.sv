module write_buffer_merge #(
  parameter INPUT_DATA_WIDTH  = 32,
  parameter INPUT_ADDR_WIDTH  = 16,
  parameter BUFFER_DEPTH      = 8,
  parameter OUTPUT_DATA_WIDTH = INPUT_DATA_WIDTH * BUFFER_DEPTH,
  parameter OUTPUT_ADDR_WIDTH = INPUT_ADDR_WIDTH - $clog2(BUFFER_DEPTH)
) (
  input  logic                         clk,
  input  logic                         srst,
  input  logic                         wr_en_in,
  input  logic [INPUT_ADDR_WIDTH-1:0]  wr_addr_in,
  input  logic [INPUT_DATA_WIDTH-1:0]  wr_data_in,
  output logic                         wr_en_out,
  output logic [OUTPUT_ADDR_WIDTH-1:0] wr_addr_out,
  output logic [OUTPUT_DATA_WIDTH-1:0] wr_data_out
);

  // Internal signals
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
        else
          base_addr <= wr_addr_in;
      end

      always_ff @(posedge clk) begin
        if (srst)
          merged_data <= '0;
        else if (wr_en_in)
          merged_data <= (wr_data_in << INPUT_DATA_WIDTH) | merged_data;
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
        if (write_complete)
          begin
            if (wr_en_out)
              wr_en_out = 1;
            else
              wr_en_out = 0;
          end
          wr_addr_out <= base_addr;
          wr_data_out <= merged_data;
          write_complete <= 1'b0;
        else
          wr_en_out = 0;
          wr_addr_out <= '0;
          wr_data_out <= '0;
        end
      end
    end
  endgenerate

endmodule
