
module FILO_RTL #(
    parameter DATA_WIDTH = 8,
    parameter FILO_DEPTH = 16
)(
    input  logic clk,
    input  logic reset,
    input  logic push,
    input  logic pop,
    input  logic data_in,
    output logic data_out,
    output logic full,
    output logic empty
);
