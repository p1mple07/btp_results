module cache_controller (
  input logic clk,
  input logic reset,
  input logic [4:0] address,
  input logic [31:0] write_data,
  input logic read,
  input logic write,
  output logic [31:0] read_data,
  output logic hit,
  output logic miss,
  output logic mem_write,
  output logic [31:0] mem_address,
  output logic [31:0] mem_write_data,
  input logic mem_ready,
  input logic [31:0] mem_read_data
);

  // Define cache parameters
  parameter CACHE_SIZE = 32;
  parameter TAG_WIDTH = 5;

  // Define cache state variables
  logic [TAG_WIDTH-1:0] tag[CACHE_SIZE];
  logic [31:0] data[CACHE_SIZE];
  logic [CACHE_SIZE-1:0] valid;
  logic [CACHE_SIZE-1:0] dirty;

  // Initialize cache with invalid tags and no valid data
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      for (int i = 0; i < CACHE_SIZE; i++) begin
        tag[i] <= '0;
        valid[i] <= 1'b0;
      end
    end else begin
      // Handle write operation
      if (write &&!hit) begin
        tag[address] <= address;
        data[address] <= write_data;
        valid[address] <= 1'b1;
        dirty[address] <= 1'b1;
      end

      // Handle read operation
      if (read &&!hit) begin
        read_data <= data[address];
      end
    end
  end

  // Detect hit and miss conditions
  assign hit = valid[address] && (tag[address] == address);
  assign miss =!hit;

  // Handle memory interface
  assign mem_address = address;
  assign mem_write = dirty[address] || write;
  assign mem_write_data = dirty[address]? data[address] : write_data;
  assign mem_ready =!dirty[address];
  assign read_data = dirty[address]? data[address] : mem_read_data;

endmodule