// rtl/sorting_engine.sv
module sorting_engine #(
  parameter N     = 8,
  parameter WIDTH  = 8
)(
  input  logic              clk,
  input  logic              rst,
  input  logic              start,
  input  logic [N*WIDTH-1:0] in_data,
  output logic              done,