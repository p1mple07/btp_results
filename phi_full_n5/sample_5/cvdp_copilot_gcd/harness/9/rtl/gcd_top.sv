module gcd_3_ip #(parameter WIDTH = 4) (
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset
   input                     go,    // Start signal for GCD computation
   input [WIDTH-1:0]        A,     // Input operand A
   input [WIDTH-1:0]        B,     // Input operand B
   input [WIDTH-1:0]        C,     // Input operand C
   input                     go_pair1, // Start signal for GCD computation of pair (A, B)
   input                     go_pair2, // Start signal for GCD computation of pair (B, C)
   output logic [WIDTH-1:0] OUT1, // Output for GCD of pair (A, B)
   output logic [WIDTH-1:0] OUT2, // Output for GCD of pair (B, C)
   output logic              done1, // Signal to indicate completion of computation for pair (A, B)
   output logic              done2, // Signal to indicate completion of computation for pair (B, C)
   output logic              done_final // Signal to indicate completion of final GCD computation
);

   // Instantiate two instances of gcd_top for pair (A, B)
   gcd_top gcd_top_ab_inst_1 (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .go                (go_pair1),          // Connect start signal for pair (A, B)
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .OUT               (OUT1),              // Connect GCD output for pair (A, B)
      .done              (done1)              // Connect done signal for pair (A, B)
   );

   // Instantiate two instances of gcd_top for pair (B, C)
   gcd_top gcd_top_bc_inst_2 (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .go                (go_pair2),          // Connect start signal for pair (B, C)
      .B                 (B),                 // Connect input B
      .C                 (C),                 // Connect input C
      .OUT               (OUT2),              // Connect GCD output for pair (B, C)
      .done              (done2)              // Connect done signal for pair (B, C)
   );

   // Instantiate third instance of gcd_top for final GCD calculation
   gcd_top gcd_top_final_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .go                (go),                 // Connect start signal for final GCD computation
      .A                 (OUT1),              // Connect GCD output for pair (A, B)
      .B                 (OUT2),              // Connect GCD output for pair (B, C)
      .OUT               (OUT),               // Connect final GCD output
      .done              (done_final)         // Connect done signal for final GCD computation
   );

   // Latching logic for final GCD computation to ensure it happens only after intermediate calculations are ready
   always_comb begin
      if (!done1 && !done2) begin
         done_final <= 1'b0;
      end else if (done1 && done2) begin
         done_final <= 1'b1;
      end
   end

endmodule
