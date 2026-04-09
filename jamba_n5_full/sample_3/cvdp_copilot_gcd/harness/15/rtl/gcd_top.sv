module lcm_3_ip #(
   parameter WIDTH = 4                // Input bit-width
   )(
   input                         clk,     // Clock signal. The design should be synchronized to the positive edge of this clock signal
   input                         rst,     // Active high Synchronous reset signal
   input  [WIDTH-1:0]            A,       // WIDTH bit input
   input  [WIDTH-1:0]            B,       // WIDTH bit input
   input  [WIDTH-1:0]            C,       // WIDTH bit input
   input                         go,      // Active high Start signal for LCM computation
   output logic  [3 * WIDTH-1:0] OUT,     // Computed LCM. 3*WIDTH bits wide
   output logic                  done     // Signal indicating that the computation is complete
  );

   // Internal signals
   logic [WIDTH-1:0] prod;           // Product of A, B, C
   logic [WIDTH-1:0] g1, g2, g3;   // GCD of pairs

   // Instantiate the gcd_3_ip module for each pair
   genvar i;
   initial @(negedge clk) begin
      for (genvar i=0; i<3; i=i+1) begin
         $nexttfm(gcd_3_ip, i, A, B, C, g1, g2, g3);
      end
   end

   // Compute overall GCD of the three GCDs
   logic gcd_total;
   gcd_top gcd_top_inst (
      .WIDTH(WIDTH)
   );

   gcd_top_inst #(
      .WIDTH(WIDTH)
   ) gcd_top_inst (
      .clk(clk),
      .rst(rst),
      .A(g1),
      .B(g2),
      .C(g3),
      .GO(go),
      .OUT(gcd_total),
      .DONE(done_top)
   );

   // Now, compute LCM: (prod) / gcd_total
   assign prod = A * B * C;
   assign lcm = (prod / gcd_total);

   // Assign to output
   assign OUT = lcm;

   // Done: assert when in S1 state
   always_ff @(posedge clk) begin
      if (rst) begin
         done <= 1'b0;
      end else begin
         done <= (done_top);
      end
   end

   // Assign controlpath_state? Not needed.
   assign controlpath_state = done_top;

   assign done = done_top;

endmodule
