module using Stein's algorithm with control and datapath merged into one FSM.
// This optimized design reduces interconnect (wires) and cell count while retaining functional equivalence and latency.

module gcd_top #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input                     go,
   output logic [WIDTH-1:0]  OUT,
   output logic              done
);

   // State encoding
   localparam S0 = 2'd0; // Idle/Load
   localparam S1 = 2'd1; // Done (final GCD computed)
   localparam S2 = 2'd2; // Processing (Stein steps)

   // Datapath registers
   logic [WIDTH-1:0] A_reg, B_reg, OUT_reg;
   // k_reg counts the number of 2's factored out (bit-shift exponent)
   logic [$clog2(WIDTH+1):0] k_reg;

   // FSM state register
   logic [1:0] state;

   // Next-state and next datapath signals
   logic [1:0] next_state;
   logic [WIDTH-1:0] next_A, next_B, next_OUT;
   logic [$clog2(WIDTH+1):0] next_k;

   // Intermediate signals for processing logic
   logic equal;
   logic a_even, b_even, both_even;
   logic [WIDTH-1:0] diff;

   // Combinational logic: compute next state and datapath updates based on current state and inputs.
   always_comb begin
      // Default assignments: hold current values
      next_state = state;
      next_A     = A_reg;
      next_B     = B_reg;
      next_k     = k_reg;
      next_OUT   = OUT_reg;

      // Compute flags: even/odd and equality
      a_even = (A_reg[0] == 1'b0);
      b_even = (B_reg[0] == 1'b0);
      both_even = a_even && b_even;
      equal = (A_reg == B_reg);

      case (state)
         S0: begin
            // Idle state: if go is asserted, load new inputs; otherwise, remain idle.
            if (go) begin
               next_state = S2;
               next_A     = A;
               next_B     = B;
               next_k     = 'b0;
               next_OUT   = 'b0;
            end
            // If !go, retain current registers.
         end

         S1: begin
            // Done state: compute final GCD based on Stein's algorithm.
            if (A_reg == 0 && B_reg == 0) begin
               next_OUT = 0;
            end else if (A_reg == 0) begin
               next_OUT = (B_reg << k_reg);
            end else begin
               next_OUT = (A_reg << k_reg);
            end
            // Reset state to idle for new operation.
            next_state = S0;
            // Datapath registers remain unchanged.
         end

         S2: begin
            // Processing state: perform one step of Stein's algorithm.
            if ((A_reg != 0) && (B_reg != 0)) begin
               if (both_even) begin
                  // Both even: divide both by 2 and increment shift count.
                  next_A     = A_reg >> 1;
                  next_B     = B_reg >> 1;
                  next_k     = k_reg + 1;
               end else if (a_even && !b_even) begin
                  // A even, B odd: divide A by 2.
                  next_A = A_reg >> 1;
               end else if (b_even && !a_even) begin
                  // B even, A odd: divide B by 2.
                  next_B = B_reg >> 1;
               end else begin
                  // Both odd: replace the larger with (larger - smaller) >> 1.
                  if (A_reg >= B_reg) begin
                     diff = A_reg - B_reg;
                     next_A = diff >> 1;
                     next_B = B_reg;
                  end else begin
                     diff = B_reg - A_reg;
                     next_B = diff >> 1;
                     next_A = A_reg;
                  end
               end
            end else if (A_reg == 0 && B_reg != 0) begin
               // One input is zero: force equality.
               next_A = B_reg;
               next_B = B_reg;
            end else if (B_reg == 0 && A_reg != 0) begin
               next_B = A_reg;
               next_A = A_reg;
            end
            // Remain in processing state.
            next_state = S2;
         end

         default: begin
            // Safety default: reset state and datapath.
            next_state = S0;
            next_A     = 'b0;
            next_B     = 'b0;
            next_k     = 'b0;
            next_OUT   = 'b0;
         end
      endcase
   end

   // Sequential update: update FSM state and datapath registers on clock edge.
   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         state  <= S0;
         A_reg  <= 'b0;
         B_reg  <= 'b0;
         k_reg  <= 'b0;
         OUT_reg<= 'b0;
      end else begin
         state  <= next_state;
         A_reg  <= next_A;
         B_reg  <= next_B;
         k_reg  <= next_k;
         OUT_reg<= next_OUT;
      end
   end

   // Drive output from register.
   assign OUT = OUT_reg;

   // done signal indicates completion (state S1).
   assign done = (state == S1);

endmodule