module gcd_top #(
   parameter WIDTH = 4
)(
   input         clk,
   input         rst,
   input  [WIDTH-1:0] A,
   input  [WIDTH-1:0] B,
   input         go,
   output logic [WIDTH-1:0] OUT,
   output logic         done
);

   // State encoding for the unified FSM
   localparam S0 = 2'd0; // Idle/Load
   localparam S1 = 2'd1; // Done (final state)
   localparam S2 = 2'd2; // Processing (Stein steps)

   // Internal datapath registers
   logic [WIDTH-1:0] A_ff, B_ff, OUT_ff;
   logic [$clog2(WIDTH+1):0] k_ff;
   logic [1:0] curr_state;

   // Next-state and datapath signals
   logic [1:0] next_state;
   logic [WIDTH-1:0] next_A_ff, next_B_ff, next_OUT;
   logic [$clog2(WIDTH+1):0] next_k_ff;
   logic equal;
   logic [WIDTH-1:0] diff;
   logic [WIDTH-1:0] gcd_val;

   // Combined FSM and datapath logic
   always_comb begin
      // Default assignments
      next_state = curr_state;
      next_A_ff  = A_ff;
      next_B_ff  = B_ff;
      next_k_ff  = k_ff;
      next_OUT   = OUT_ff;
      equal      = (A_ff == B_ff);
      diff       = '0;

      case (curr_state)
         S0: begin
            // Load inputs when go is asserted
            next_state = (go) ? S2 : S0;
            next_A_ff  = A;
            next_B_ff  = B;
            next_k_ff  = '0;
            next_OUT   = '0;
         end

         S1: begin
            // Final state: compute GCD value
            if (A_ff == 0 && B_ff == 0)
               gcd_val = 0;
            else if (A_ff == 0)
               gcd_val = B_ff << k_ff;
            else
               gcd_val = A_ff << k_ff;
            next_OUT = gcd_val;
            next_state = S0; // Return to idle after finishing
         end

         S2: begin
            // Processing state: one step of Stein's algorithm
            if ((A_ff != 0) && (B_ff != 0)) begin
               // Determine even/odd flags from the LSB
               if ((A_ff[0] == 1'b0) && (B_ff[0] == 1'b0)) begin
                  next_A_ff = A_ff >> 1;
                  next_B_ff = B_ff >> 1;
                  next_k_ff = k_ff + 1;
               end else if ((A_ff[0] == 1'b0) && (B_ff[0] != 1'b0)) begin
                  next_A_ff = A_ff >> 1;
               end else if ((A_ff[0] != 1'b0) && (B_ff[0] == 1'b0)) begin
                  next_B_ff = B_ff >> 1;
               end else begin
                  // Both odd: subtract and shift the difference
                  if (A_ff >= B_ff) begin
                     diff = A_ff - B_ff;
                     next_A_ff = diff >> 1;
                     next_B_ff = B_ff;
                  end else begin
                     diff = B_ff - A_ff;
                     next_B_ff = diff >> 1;
                     next_A_ff = A_ff;
                  end
               end
            end else if ((A_ff == 0) && (B_ff != 0)) begin
               // If one is zero and the other nonzero, force equality
               next_A_ff = B_ff;
               next_B_ff = B_ff;
            end else if ((B_ff == 0) && (A_ff != 0)) begin
               next_A_ff = A_ff;
               next_B_ff = A_ff;
            end

            // Check for termination: if inputs are equal, move to done state
            if (equal)
               next_state = S1;
            else
               next_state = S2;
         end

         default: begin
            // Fallback to idle state
            next_state = S0;
            next_A_ff  = '0;
            next_B_ff  = '0;
            next_k_ff  = '0;
            next_OUT   = '0;
         end
      endcase
   end

   // Sequential update of state and datapath registers
   always_ff @(posedge clk) begin
      if (rst) begin
         A_ff      <= '0;
         B_ff      <= '0;
         k_ff      <= '0;
         OUT_ff    <= '0;
         curr_state<= S0;
      end else begin
         A_ff      <= next_A_ff;
         B_ff      <= next_B_ff;
         k_ff      <= next_k_ff;
         OUT_ff    <= next_OUT;
         curr_state<= next_state;
      end
   end

   // Drive outputs from registers
   assign OUT = OUT_ff;
   assign done = (curr_state == S1);

endmodule