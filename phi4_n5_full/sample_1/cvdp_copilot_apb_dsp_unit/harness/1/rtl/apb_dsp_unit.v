// File: rtl/apb_dsp_unit.v
`timescale 1ns/1ps
module apb_dsp_unit (
  input  wire         pclk,
  input  wire         presetn,   // active-low asynchronous reset
  input  wire [9:0]   paddr,     // APB address bus (10 bits)
  input  wire         pselx,     // APB select signal
  input  wire         penable,   // APB enable signal
  input  wire         pwrite,    // APB write enable (1 = write, 0 = read)
  input  wire [7:0]   pwdata,    // APB write data bus (8 bits)
  output reg          pread,     // APB ready signal
  output reg [7:0]    prdata,    // APB read data bus (8 bits)
  output reg          pslverr,   // APB slave error signal
  output reg          sram_valid // Signal to latch SRAM write (active one cycle)
);

  //-------------------------------------------------------------------------
  // Internal registers for configuration
  //-------------------------------------------------------------------------
  // r_operand_1 and r_operand_2 are used as memory addresses (10 bits)
  reg [9:0] r_operand_1;
  reg [9:0] r_operand_2;
  // r_Enable: mode register (8 bits)
  //   0: DSP disabled
  //   1: Addition mode
  //   2: Multiplication mode
  //   3: Data Writing mode
  reg [7:0] r_Enable;
  // r_write_address: memory address where data will be written (10 bits)
  reg [9:0] r_write_address;
  // r_write_data: data to be written into memory (8 bits)
  reg [7:0] r_write_data;
  // r_result: computed result stored at APB address 0x5 (8 bits)
  reg [7:0] r_result;

  //-------------------------------------------------------------------------
  // State machine for APB transactions
  //-------------------------------------------------------------------------
  // States: 00 = IDLE, 01 = READ, 10 = WRITE
  reg [1:0] state;
  // Flag to trigger SRAM write in data writing mode (r_Enable==3)
  reg       write_trigger;

  //-------------------------------------------------------------------------
  // SRAM Memory Model
  //-------------------------------------------------------------------------
  // 1 KB SRAM modeled as an array of 1024 bytes
  reg [7:0] sram_mem [0:1023];

  //-------------------------------------------------------------------------
  // APB Transaction State Machine
  //-------------------------------------------------------------------------
  always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      state            <= 2'b00;  // IDLE
      pread            <= 1'b0;
      pslverr          <= 1'b0;
      r_operand_1      <= 10'd0;
      r_operand_2      <= 10'd0;
      r_Enable         <= 8'd0;
      r_write_address