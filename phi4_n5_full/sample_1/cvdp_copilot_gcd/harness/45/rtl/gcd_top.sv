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

   // State encoding: S0 = Idle/Load, S1 = Done, S2 = Processing
   localparam S0 = 2'd0;
   localparam S1 = 2'd1;
   localparam S2 = 2'd2;

   // Datapath registers
   logic [1:0] state;
   logic [WIDTH-1:0] A_ff, B_ff, OUT_ff;
   logic [$clog2(WIDTH+1):0] k_ff;

   // Next-state and next datapath signals
   logic [1:0] next_state;
   logic [WIDTH-1:0] next_A_ff, next_B_ff, next_OUT;
   logic [$clog2(WIDTH+1):0] next_k_ff;
   logic equal;
   logic [WIDTH-1:0] diff;
   logic a_even, b_even, both_even;

   // Combined combinational logic for control and datapath
   always_comb begin
      // Default assignments
      next_state = state;
      next_A_ff  = A_ff;
      next_B_ff  = B_ff;
      next_k_ff  = k_ff;
      next_OUT   = OUT_ff;
      equal      = (A_ff == B_ff);

      case (state)
         S0: begin
            // Idle/Load: Load inputs; if go asserted, move to processing state S2
            next_A_ff = A;
            next_B_ff = B;
            next_k_ff = 'b0;
            next_OUT  = 'b0;
            if (go)
               next_state = S2;
            else
               next_state = S0;
         end
         S1: begin
            // Finalization: Compute GCD and transition back to idle
            if (A_ff == 0 && B_ff == 0)
               next_OUT = 0;
            else if (A_ff == 0)
               next_OUT = (B_ff << k_ff);
            else
               next_OUT = (A_ff << k_ff);
            next_state = S0;
            // Datapath registers remain unchanged in S1
         end
         S2: begin
            // Processing: Apply one step of Stein's algorithm
            if ((A_ff != 0) && (B_ff != 0)) begin
               a_even = (A_ff[0] == 1'b0);
               b_even = (B_ff[0] == 1'b0);
               both_even = a_even && b_even;
               if (both_even) begin
                  next_A_ff = A_ff >> 1;
                  next_B_ff = B_ff >> 1;
                  next_k_ff = k_ff + 1;
               end else if (a_even && !b_even) begin
                  next_A_ff = A_ff >> 1;
               end else if (b_even && !a_even) begin
                  next_B_ff = B_ff >> 1;
               end else begin
                  // Both odd: subtract smaller from larger and shift right by 1
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
               // Force equality if one input is zero
               next_A_ff = B_ff;
               next_B_ff = B_ff;
            end else if (B_ff == 0 && A_ff != 0) begin
               next_B_ff = A_ff;
               next_A_ff = A_ff;
            end
            // Transition: if inputs are equal, move to done state S1; otherwise, remain in S2
            if (equal)
               next_state = S1;
            else
               next_state = S2;
         end
         default: begin
            next_state = S0;
            next_A_ff  = 'b0;
            next_B_ff  = 'b0;
            next_k_ff  = 'b0;
            next_OUT   = 'b0;
         end
      endcase
   end

   // Sequential update: update both control and datapath registers together
   always_ff @(posedge clk) begin
      if (rst) begin
         state   <= S0;
         A_ff    <= 'b0;
         B_ff    <= 'b0;
         k_ff    <= 'b0;
         OUT_ff  <= 'b0;
      end else begin
         state   <= next_state;
         A_ff    <= next_A_ff;
         B_ff    <= next_B_ff;
         k_ff    <= next_k_ff;
         OUT_ff  <= next_OUT;
      end
   end

   // Drive outputs
   assign OUT = OUT_ff;
   assign done = (state == S1);

endmodule