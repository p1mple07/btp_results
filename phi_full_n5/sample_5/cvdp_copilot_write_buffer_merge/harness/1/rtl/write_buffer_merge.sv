module write_buffer_merge #(
  parameter INPUT_DATA_WIDTH  = 32,
  parameter INPUT_ADDR_WIDTH  = 16,
  parameter BUFFER_DEPTH      = 8,
  parameter OUTPUT_DATA_WIDTH = INPUT_DATA_WIDTH * BUFFER_DEPTH,
  parameter OUTPUT_ADDR_WIDTH = INPUT_ADDR_WIDTH - $clog2(BUFFER_DEPTH)
) (
  input  logic clk,
  input  logic srst,
  input  logic wr_en_in,
  input  logic [INPUT_ADDR_WIDTH-1:0] wr_addr_in,
  input  logic [INPUT_DATA_WIDTH-1:0] wr_data_in,
  output logic wr_en_out,
  output logic [OUTPUT_ADDR_WIDTH-1:0] wr_addr_out,
  output logic [OUTPUT_DATA_WIDTH-1:0] wr_data_out
);

  // Internal signals for buffer tracking and management
  logic [$clog2(BUFFER_DEPTH)-1:0] write_count;
  logic [OUTPUT_ADDR_WIDTH-1:0] base_addr;
  logic [OUTPUT_DATA_WIDTH-1:0] merged_data;
  logic write_complete;

  generate
    if (BUFFER_DEPTH > 1) begin
      // Write count logic: Counts the number of writes in the buffer
      always_ff @(posedge clk) begin
        if (srst) 
          write_count <= '0;
        else if (wr_en_in)
          write_count <= write_count + 1;
      end

      // Base address logic: Captures the address of the first write in the buffer
      always_ff @(posedge clk) begin
        if (srst)
          base_addr <= '0;
        else if (write_count == 0) begin
          base_addr = wr_addr_in >> ($clog2(BUFFER_DEPTH));
        end
      end

      // Merged data logic: Concatenates incoming data into the buffer
      always_ff @(posedge clk) begin
        if (srst)
          merged_data <= '0;
        else if (wr_en_in) begin
          merged_data <= {merged_data{1'b0}} << (INPUT_DATA_WIDTH * (write_count - 1));
          merged_data[INPUT_DATA_WIDTH*write_count-1:INPUT_DATA_WIDTH*write_count] <= wr_data_in;
        end
      end

      // Write completion logic: Indicates when the buffer is full
      always_ff @(posedge clk) begin
        if (srst)
          write_complete <= 1'b0;
        else if ((write_count == (BUFFER_DEPTH - 1)) && wr_en_in)
          write_complete <= 1'b1;
        else
          write_complete <= 1'b0;
      end

      // Output logic for BUFFER_DEPTH > 1
      assign wr_en_out = write_complete;
      assign wr_addr_out = base_addr;
      assign wr_data_out = merged_data;

    end else begin

      // Passthrough logic for BUFFER_DEPTH = 1
      assign wr_en_out = srst;
      assign wr_addr_out = wr_addr_in;
      assign wr_data_out = wr_data_in;

    end
  endgenerate

endmodule
