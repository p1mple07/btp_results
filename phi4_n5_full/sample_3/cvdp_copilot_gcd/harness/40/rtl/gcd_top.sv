
module lcm_3_ip #(
   parameter WIDTH = 4                    // Input bit-width
   )(
   input                         clk,
   input                         rst,
   input  [WIDTH-1:0]            A,
   input  [WIDTH-1:0]            B,
   input  [WIDTH-1:0]            C,
   input                         go,
   output logic  [3 * WIDTH-1:0] OUT,   // Updated output width
   output logic                  done
);
