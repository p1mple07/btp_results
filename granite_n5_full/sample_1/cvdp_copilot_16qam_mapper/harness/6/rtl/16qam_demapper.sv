module qam16_demapper_interpolated #(
  parameter int unsigned N = 4,
  parameter int unsigned OUT_WIDTH = 4,
  parameter int unsigned IN_WIDTH = 3
) (
  input logic [N+N/2*IN_WIDTH-1:0] I,
  input logic [N+N/2*IN_WIDTH-1:0] Q,
  output logic [N*OUT_WIDTH-1:0] bits,
  output logic error_flag
);

  // Input parsing and error detection logic here...

  // Mapping I/Q components to bits logic here...

  // Output arrangement logic here...

endmodule