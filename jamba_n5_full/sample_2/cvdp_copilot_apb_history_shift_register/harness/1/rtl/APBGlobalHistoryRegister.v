`timescale 1ns / 1ps

module apbgshr (
    input pclk,
    input presetn,
    input [9:0] paddr,
    input pselx,
    input penable,
    input pwrite,
    input [7:0] pwdata,
    output reg ready,
    output reg [9:0] prdata,
    output [3:0] pslverr,
    output history_full,
    output history_empty,
    output interrupt_full,
    output interrupt_error,
    output [3:0] predict_history
);
