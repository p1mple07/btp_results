module gcd_3_ip #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
) (
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input  [WIDTH-1:0]        C,     // Input operand C (third input for GCD calculation)
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Instantiate two instances of gcd_top to calculate GCD of (A,B) and (B,C)
   gcd_top gcd_top1_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .go                (go),                // Connect go signal
      .OUT               (gcd_top1_OUT),     // Connect output of gcd_top1
      .done              (gcd_top1_done)      // Connect done signal of gcd_top1
   );

   gcd_top gcd_top2_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (B),                 // Connect input B
      .B                 (C),                 // Connect input C
      .go                (gcd_top1_done & gcd_top2_go), // Connect go signal based on gcd_top1_done
      .OUT               (gcd_top2_OUT),     // Connect output of gcd_top2
      .done              (gcd_top2_done)      // Connect done signal of gcd_top2
   );

   gcd_top gcd_top3_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (gcd_top1_OUT),     // Connect output of gcd_top1
      .B                 (gcd_top2_OUT),     // Connect output of gcd_top2
      .go                (gcd_top3_go),       // Connect go signal
      .OUT               (OUT),                // Connect output of gcd_top3
      .done              (done)                // Connect done signal
   );

   // Generate go signal for gcd_top3 based on done signals of gcd_top1 and gcd_top2
   assign gcd_top3_go = gcd_top1_done & gcd_top2_done;

endmodule
