
`timescale 1ns / 1ps
module sipo_top #(parameter DATA_WIDTH = 16,
                  parameter SHIFT_DIRECTION = 1,
                  parameter CODE_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH+1))
                 (input clk,
                  input rst,
                  input serial_in,
                  input shift_en,
                  input received, // Actually "received" is input for ECC?
                  output done,
                  output [DATA_WIDTH-1:0] data_out,
                  output [CODE_WIDTH-1:0] encoded,
                  output error_detected,
                  output error_corrected);
