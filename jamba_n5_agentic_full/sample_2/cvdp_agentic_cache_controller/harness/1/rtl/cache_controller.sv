`timescale 1ns/1ps
module cache_controller_tb;

  reg clk, reset;
  reg [4:0] address;
  reg [31:0] write_data;
  reg read;
  reg write;
  reg read_data;
  reg write_en;
  reg [31:0] mem_address;
  reg [31:0] mem_write_data;
  reg mem_read_data;
  reg mem_ready;

  cache_controller uut (
    .clk             (clk),
    .reset           (reset),
    .address         (address),
    .write_data      (write_data),
    .read            (read),
    .write           (write),
    .read_data       (read_data),
    .write_en        (write_en),
    .mem_address     (mem_address),
    .mem_write_data  (mem_write_data),
    .mem_read_data   (mem_read_data),
    .mem_ready       (mem_ready)
  );

  // Cache initialization
  initial begin
    for (int i = 0; i < 32; i++) begin
      uut.cache[i].valid = 0;
    end
  end

  initial begin
    #100 $finish;
  end

endmodule

module cache_controller (
  input clk,
  input reset,
  input [4:0] address,
  input write,
  input read,
  input write_en,
  input [31:0] mem_address,
  input [31:0] mem_write_data,
  input mem_read_data,
  input mem_ready,
  output reg [31:0] read_data,
  output reg hit,
  output reg miss,
  output reg mem_write,
  output reg mem_address,
  output reg mem_write_data,
  output reg mem_read_data,
  output reg mem_ready
);

  localparam num_lines = 32;
  localparam block_size = 32;
  localparam offset_bits = 5;
  localparam index_bits = 5;

  reg [index_bits:0] idx;
  reg [offset_bits:0] tag;
  reg [31:0] data;
  reg [31:0] mem_addr;
  reg [31:0] mem_write_dat;
  reg [31:0] mem_read_dat;
  reg [31:0] mem_ready;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      idx <= 5'b00000;
      tag <= 5'b0;
      data <= 32'd0;
      mem_addr <= 52'h00000000;
      mem_write_dat <= 32'd0;
      mem_read_dat <= 32'd0;
      mem_ready <= 1'b0;
    end else begin
      idx = address[index_bits:0];
      tag = address[index_bits-1 + offset_bits : index_bits];
      data = mem_addr[31:27] ? mem_write_dat : mem_read_dat;
      mem_addr = mem_addr[31:27] ? mem_write_dat : mem_read_dat;
      mem_write_dat = data;
      mem_read_dat = data;
      mem_ready = 1'b1;
    end
  end

  assign read_data = data;
  assign hit = (tag == mem_addr) && (read);
  assign miss = !hit;
  assign mem_write = write_en;
  assign mem_write_data = mem_write_dat;
  assign mem_read_data = read_data;
  assign mem_ready = mem_ready;

endmodule
