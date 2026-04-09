module qam16_demapper_interpolated #(
  parameter int N = 4,
  parameter int OUT_WIDTH = 4,
  parameter int IN_WIDTH = 3
) (
  input logic signed [IN_WIDTH*N - 1:0] i,
  input logic signed [IN_WIDTH*N - 1:0] q,
  output logic [N*OUT_WIDTH - 1:0] bits,
  output logic error_flag
);

  // Your implementation goes here

endmodule