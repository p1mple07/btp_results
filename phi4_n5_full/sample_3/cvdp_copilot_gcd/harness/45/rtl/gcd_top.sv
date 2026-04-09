module gcd_top #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input      [WIDTH-1:0]    A,
   input      [WIDTH-1:0]    B,
   input                     go,
   output logic [WIDTH-1:0]  OUT,
   output logic              done
);

   // State encoding for the combined FSM
   localparam S0 = 2'd0; // Idle/Load
   localparam S1 = 2'd1; // Finalize result (Done)
   localparam S2 = 2'd2; // Processing (Stein's steps)

   // Internal registers for datapath
   logic [1:0] state;
   logic [WIDTH-1:0] A_ff, B_ff, OUT_ff;
   logic [$clog2(WIDTH+1):0] k_ff;
   logic [WIDTH-1:0] diff;

   // Combinational outputs
   assign done  = (state == S1);
   assign OUT   = OUT_ff;

   // Combined FSM: control and datapath logic merged into one sequential block
   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         state   <= S0;
         A_ff    <= '0;
         B_ff    <= '0;
         k_ff    <= '0;
         OUT_ff  <= '0;
      end else begin
         case (state)
            S0: begin
               // Idle state: wait for go signal to load inputs
               if (go) begin
                  state   <= S2;
                  A_ff    <= A;
                  B_ff    <= B;
                  k_ff    <= '0;
                  OUT_ff  <= '0;
               end else begin
                  state   <= S0;
               end
            end

            S2: begin
               // Processing state: perform one iteration of Stein's algorithm
               // Termination conditions: if A_ff equals B_ff, or one is zero.
               if (A_ff == B_ff) begin
                  // Both nonzero and equal: finalize result
                  OUT_ff <= (A_ff << k_ff);
                  state  <= S1;
               end else if (A_ff == 0) begin
                  // One operand is zero
                  OUT_ff <= (B_ff << k_ff);
                  state  <= S1;
               end else if (B_ff == 0) begin
                  OUT_ff <= (A_ff << k_ff);
                  state  <= S1;
               end else begin
                  // Apply one iteration of Stein's algorithm
                  if ((A_ff[0] == 1'b0) && (B_ff[0] == 1'b0)) begin
                     // Both even: divide by 2 and increment k
                     A_ff <= A_ff >> 1;
                     B_ff <= B_ff >> 1;
                     k_ff <= k_ff + 1;
                     state <= S2;
                  end else if ((A_ff[0] == 1'b0) && (B_ff[0] != 1'b0)) begin
                     // A is even, B is odd: divide A by 2
                     A_ff <= A_ff >> 1;
                     state <= S2;
                  end else if ((B_ff[0] == 1'b0) && (A_ff[0] != 1'b0)) begin
                     // B is even, A is odd: divide B by 2
                     B_ff <= B_ff >> 1;
                     state <= S2;
                  end else begin
                     // Both odd: subtract the smaller from the larger and divide by 2
                     if (A_ff >= B_ff) begin
                        diff = A_ff - B_ff;
                        A_ff <= diff >> 1;
                        B_ff <= B_ff;
                     end else begin
                        diff = B_ff - A_ff;
                        B_ff <= diff >> 1;
                        A_ff <= A_ff;
                     end
                     state <= S2;
                  end
               end
            end

            S1: begin
               // Done state: result is finalized; return to idle
               state <= S0;
            end

            default: begin
               state <= S0;
            end
         endcase
      end
   end

endmodule