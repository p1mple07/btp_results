// -*- mode: utf-8 -*-
kadence:verilog
include "custom_byte_enable_ram.sv"

localparam XLEN  = 32;
localparam LINES = 8192;
localparam ADDR_WIDTH = $clog2(LINES);

localparam WORD_WIDTH = 8;
localparam BYTES_PER_WORD = XLEN / WORD_WIDTH;

parameter [ADDR_WIDTH-1:0] addr_a, addr_b;
parameter [BYTES_PER_WORD-1:0] be_a, be_b;
parameter [XLEN-1:0] data_in_a, data_in_b;
parameter [XLEN-1:0] data_out_a, data_out_b;

// Stage 1 Registers
reg [ADDR_WIDTH-1:0] addr_reg_a, addr_reg_b;
reg [BYTES_PER_WORD-1:0] be_reg_a, be_reg_b;
reg [XLEN-1:0] data_in_reg_a, data_in_reg_b;
reg [XLEN-1:0] data_out_reg_a, data_out_reg_b;

// Memory Array
reg [XLEN-1:0] memory [LINES-1:0];

always @(posedge_clk) begin
  // Stage 1: Capture inputs
  addr_reg_a <= addr_a;
  addr_reg_b <= addr_b;
  be_reg_a <= be_a;
  be_reg_b <= be_b;
  data_in_reg_a <= data_in_a;
  data_in_reg_b <= data_in_b;

  // Stage 2: Process writes
  if (en_a && en_b && addr_reg_a == addr_reg_b) begin
    // Collision detected
    if (be_reg_a & be_reg_b) begin
      // Port A's byte is higher priority
      data_out_reg_a <= data_in_reg_a;
      data_out_reg_b <= data_in_reg_b;
    else if (!be_reg_a && be_reg_b) begin
      data_out_reg_a <= data_in_reg_b;
      data_out_reg_b <= data_in_reg_a;
    else begin
      // No collision, nothing happens
    end
  end else if (en_a) begin
    data_out_reg_a <= data_in_reg_a;
    data_out_reg_b <= data_in_reg_b;
  end else if (en_b) begin
    data_out_reg_a <= data_in_reg_a;
    data_out_reg_b <= data_in_reg_b;
  end

  // Stage 3: Output results
  data_out_a <= data_out_reg_a;
  data_out_b <= data_out_reg_b;
end

// Initializations
initial begin
  clk = 0;
  forever #5 clk = ~clk;
end

initial begin
  addr_a = 0;
  addr_b = 0;
  en_a = 0;
  en_b = 0;
  be_a = 4'b0000;
  be_b = 4'b0000;
  data_in_a = 32'h0;
  data_in_b = 32'h0;

  #10;
  addr_a = 0;
  en_a = 1;
  be_a = 4'b1111;
  data_in_a = 32'hDEADBEEF;
  #10;
  en_a = 0;
  #30;
  $display("Test 1: Port A read at addr 0 = %h (Expected: DEADBEEF)", data_out_a);

  addr_b = 1;
  en_b = 1;
  be_b = 4'b1100;
  data_in_b = 32'hCAFEBABE;
  #10;
  en_b = 0;
  #30;
  $display("Test 2: Port B read at addr 1 = %h (Expected: CAFE0000)", data_out_b);

  addr_a = 2;
  addr_b = 2;
  en_a = 1;
  en_b = 1;
  be_a = 4'b0011;
  data_in_a = 32'h00001234;
  be_b = 4'b1100;
  data_in_b = 32'hABCD0000;
  #10;
  en_a = 0;
  en_b = 0;
  #30;
  $display("Test 3: Port A read at addr 2 = %h (Expected: ABCD1234)", data_out_a);
  $display("Test 3: Port B read at addr 2 = %h (Expected: ABCD1234)", data_out_b);

  addr_a = 3;
  en_a = 1;
  be_a = 4'b0011;
  data_in_a = 32'h00001234;
  #10;
  en_a = 0;
  #30;
  $display("Test 4: Port A read at addr 3 = %h (Expected: ABCD1234)", data_out_a);

  addr_a = 5;
  en_a = 1;
  be_a = 4'b1111;
  data_in_a = 32'hAAAAAAAA;
  addr_b = 6;
  en_b = 1;
  be_b = 4'b1111;
  data_in_b = 32'h55555555;
  #10;
  en_a = 0;
  en_b = 0;
  #30;
  $display("Test 5: Port A read at addr 5 = %h (Expected: AAAAAAAA)", data_out_a);
  $display("Test 5: Port B read at addr 6 = %h (Expected: 55555555)", data_out_b);
end