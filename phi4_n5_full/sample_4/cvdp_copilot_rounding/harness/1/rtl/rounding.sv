
module rounding #(parameter WIDTH = 24)
(
  input logic [WIDTH-1:0] in_data, // Input value for rounding
  input logic sign, // Indicates sign of input (1: negative, 0: positive)
  input logic roundin, // Round bit
  input logic stickyin, // Sticky bit for precision
  input logic [2:0] rm, // Rounding mode
  output logic [WIDTH-1:0] out_data, // Rounded output
  output logic inexact, // Indicates precision loss
  output logic cout, // Detects overflow in the rounding operation
  output logic r_up // Indicates if rounding up occurred
);
