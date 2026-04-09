module gcd_top #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input                     go,
   input                     equal,
   output logic [WIDTH-1:0]  OUT,
   output logic              done
);

   // Datapath for Stein's Algorithm
   logic [WIDTH-1:0] A_ff, B_ff, OUT_ff;
   logic [$clog2(WIDTH+1):0] k_ff;

   // Next-state signals
   logic [WIDTH-1:0] next_A_ff, next_B_ff, next_OUT;
   logic [$clog2(WIDTH+1):0] next_k_ff;

   // State encoding
   localparam S0 = 2'd0; // Idle/Load
   localparam S1 = 2'd1; // Compute done
   localparam S2 = 2'd2; // Processing (Stein steps)

   // Combinational logic for next states and outputs
   always_comb begin
      // Default next values
      next_A_ff = A_ff;
      next_B_ff = B_ff;
      next_k_ff = k_ff;
      next_OUT  = OUT_ff;
      gcd_val   = OUT_ff; // Default to current OUT value
      diff      = 'b0;

      // Determine intermediate flags
      a_even    = (A_ff[0] == 1'b0);
      b_even    = (B_ff[0] == 1'b0);
      both_even = a_even && b_even;
      equal     = (A_ff == B_ff);

      case (controlpath_state)
         S0: begin
            // Load inputs at S0
            next_A_ff = A;
            next_B_ff = B;
            next_k_ff = 'b0;
            next_OUT  = 'b0; 
         end

         S1: begin
            // Done state: finalize the GCD
            // If A_ff == B_ff: gcd = A_ff << k_ff
            // If both zero => gcd=0
            // If one zero => gcd = nonzero << k_ff
            if (A_ff == 0 && B_ff == 0) begin
               gcd_val = 0;
            end else if (A_ff == 0) begin
               gcd_val = (B_ff << k_ff);
            end else begin
               // A_ff == B_ff
               gcd_val = (A_ff << k_ff);
            end
            next_OUT = gcd_val;
         end

         S2: begin
            // One step of Stein's algorithm
            // If not done, apply rules:
            // Both even: A=A/2, B=B/2, k++
            // A even, B odd: A=A/2
            // B even, A odd: B=B/2
            // Both odd: larger = (larger - smaller)/2

            if ((A_ff != 0) && (B_ff != 0)) begin
               // Both nonzero
               if (both_even) begin
                  next_A_ff = A_ff >> 1;
                  next_B_ff = B_ff >> 1;
                  next_k_ff = k_ff + 1;
               end else if (a_even && !b_even) begin
                  next_A_ff = A_ff >> 1;
               end else if (b_even && !a_even) begin
                  next_B_ff = B_ff >> 1;
               end else begin
                  // both odd
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
            end else if (A_ff == 0 && B_ff != 0) begin
               // If one is zero and the other is nonzero, make them equal to move to done next cycle
               next_A_ff = B_ff;
               next_B_ff = B_ff;
            end else if (B_ff == 0 && A_ff != 0) begin
               next_B_ff = A_ff;
               next_A_ff = A_ff;
            end
            // If both are zero, they are already equal, will move to done soon.
         end

         default: begin
            // Default reset values
            next_A_ff = 'b0;
            next_B_ff = 'b0;
            next_k_ff = 'b0;
            next_OUT  = 'b0;
         end
      endcase
   end

   // Sequential updates
   always_ff @(posedge clk) begin
      if (rst) begin
         A_ff  <= 'b0;
         B_ff  <= 'b0;
         k_ff  <= 'b0;
         OUT_ff <= 'b0;
      end else begin
         A_ff  <= next_A_ff;
         B_ff  <= next_B_ff;
         k_ff  <= next_k_ff;
         OUT_ff <= next_OUT;
      end
   end

   // OUT is driven from register
   assign OUT = OUT_ff;

endmodule