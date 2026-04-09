module queue #(
   parameter int unsigned DEPTH = 8,
   parameter int unsigned DBITS = 32,
   parameter int unsigned ALMOST_EMPTY_THRESHOLD = 16,
   parameter int unsigned ALMOST_FULL_THRESHOLD = 48
 ) (
   input  logic clk_i,
   input  logic rst_ni,
   input  logic clr_i,
   input  logic ena_i,
   input  logic we_i,
   input  logic [DBITS-1:0] d_i,
   input  logic re_i,
   output logic [DBITS-1:0] q_o,
   output logic empty_o,
   output logic full_o,
   output logic almost_empty_o,
   output logic almost_full_o
 );

  // Implement the queue module functionality here

 endmodule