module gcd_3_ip #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
   )(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input  [WIDTH-1:0]        C,     // Input operand C
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Two independent GCD chains for the first two pairs
   gcd_top gcd1 (
      .clk               (clk),
      .rst               (rst),
      .go                (go),
      .A                 (A),
      .B                 (B),
      .C                 (C),
      .controlpath_state (gcd1.controlpath_state),
      .done              (gcd1.done),
      .equal             (equal1),
      .greater_than      (greater1),
      .OUT               (gcd1.OUT)
   );

   // Second GCD chain for the second pair (B, C)
   gcd_top gcd2 (
      .clk               (clk),
      .rst               (rst),
      .go                (go),
      .A                 (B),
      .B                 (C),
      .C                 (C),
      .controlpath_state (gcd2.controlpath_state),
      .done              (gcd2.done),
      .equal             (equal2),
      .greater_than      (greater2),
      .OUT               (gcd2.OUT)
   );

   // Final GCD stage that combines the two previous results
   gcd_top gcd_final (
      .clk               (clk),
      .rst               (rst),
      .go                (go),
      .A                 (gcd1.OUT),
      .B                 (gcd2.OUT),
      .C                 (gcd1.OUT),
      .controlpath_state (gcd1.controlpath_state),
      .done              (gcd_final.done),
      .equal             (equal_final),
      .greater_than      (greater_final),
      .OUT               (gcd_final.OUT)
   );

endmodule
