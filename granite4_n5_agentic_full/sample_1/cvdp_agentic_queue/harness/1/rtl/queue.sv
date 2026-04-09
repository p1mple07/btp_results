module queue #(
   parameter int unsigned DEPTH = 8,
   parameter int unsigned DBITS = 32,
   parameter int unsigned ALMOST_EMPTY_THRESHOLD = DEPTH / 4,
   parameter int unsigned ALMOST_FULL_THRESHOLD   = DEPTH * 3 / 4
)(
   input wire clk_i,
   input wire rst_ni,
   input wire clr_i,
   input wire ena_i,
   input wire we_i,
   input wire [DBITS-1:0] d_i,
   input wire re_i,
   output logic empty_o,
   output logic full_o,
   output logic almost_empty_o,
   output logic almost_full_o,
   output logic [DBITS-1:0] q_o
);

   // Code implementation goes here

endmodule