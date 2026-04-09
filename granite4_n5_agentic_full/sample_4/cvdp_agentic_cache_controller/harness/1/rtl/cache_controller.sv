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

localparam CACHE_SIZE = 32;
localparam TAG_WIDTH = 5;

logic [TAG_WIDTH-1:0] tag[CACHE_SIZE];
logic [31:0] data[CACHE_SIZE];
logic [31:0] cache_read_data;
logic [31:0] cache_write_data;
logic [TAG_WIDTH-1:0] cache_tag;
logic cache_hit;
logic cache_miss;

always_comb begin
  hit = 1'b0;
  miss = 1'b0;
  cache_read_data = 32'b0;
  cache_write_data = 32'b0;
  cache_tag = '0;

  for (int i=0; i<CACHE_SIZE; i++) begin
    if (tag[i] == address[TAG_WIDTH-1:0]) begin
      hit = 1'b1;
      cache_read_data = data[i];
      break;
    end
  end

  if (!hit) begin
    miss = 1'b1;
  end
end

always_ff @(posedge clk or posedge reset) begin
  if (reset) begin
    tag <= '0;
    data <= '0;
  end else begin
    if (read && hit) begin
      cache_read_data <= read_data;
    end
    if (write &&!hit) begin
      cache_write_data <= write_data;
      cache_tag <= address[TAG_WIDTH-1:0];
    end
  end
end

always_ff @(posedge clk or posedge reset) begin
  if (reset) begin
    mem_address <= '0;
    mem_write <= 1'b0;
    mem_write_data <= '0;
  end else begin
    if (write && hit) begin
      mem_write <= 1'b1;
      mem_write_data <= cache_write_data;
      mem_address <= cache_tag;
    end
    if (read && hit) begin
      mem_read_data <= cache_read_data;
    end
  end
end

assign read_data = cache_hit? cache_read_data : 'x;
assign miss = ~hit;

endmodule