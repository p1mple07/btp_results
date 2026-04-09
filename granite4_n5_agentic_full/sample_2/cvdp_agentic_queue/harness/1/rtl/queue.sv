module queue #(
  parameter int unsigned DEPTH = 8, // Number of queue entries
  parameter int unsigned DBITS = 64 // Data width
) (
  input  wire                  clk_i,    // Clock
  input  wire                  rst_ni,   // Asynchronous reset active low
  input  wire                  clr_i,    // Synchronous clear
  input  wire                  ena_i,    // Enable clock domain crossing
  input  wire [DBITS-1:0]   d_i,      // Data input
  input  wire                  we_i,     // Write enable
  output reg [DBITS-1:0]   q_o,      // Data output
  input  wire                  re_i,     // Read enable
  output reg                   empty_o,  // Indicates if the queue is empty
  output reg                   full_o,   // Indicates if the queue is full
  output reg                   almost_empty_o, // Almost empty indicator
  output reg                   almost_full_o,  // Almost full indicator
  parameter int unsigned ALMOST_EMPTY_THRESHOLD = 2, // Programmable threshold for almost empty signal
  parameter int unsigned ALMOST_FULL_THRESHOLD = 3   // Programmable threshold for almost full signal
);

  // Your implementation code goes here
  
endmodule