module gcd_top #(
   parameter WIDTH = 4
)(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input                     go,    // Start signal to begin GCD computation
   output logic [WIDTH-1:0]  OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // FSM state encoding
   localparam S0 = 2'd0;  // Initialization state: load inputs
   localparam S1 = 2'd1;  // Computation complete: output result
   localparam S2 = 2'd2;  // A_ff > B_ff: subtract B_ff from A_ff
   localparam S3 = 2'd3;  // B_ff > A_ff: subtract A_ff from B_ff

   // Internal registers for state and datapath
   logic [1:0] state, next_state;
   logic [WIDTH-1:0] A_ff, B_ff;
   logic equal, greater_than;

   // Sequential logic: state update and datapath register updates
   always_ff @(posedge clk) begin
      if (rst) begin
         state  <= S0;
         A_ff   <= '0;
         B_ff   <= '0;
         OUT    <= '0;
      end else begin
         state <= next_state;
         case (state)
            S0: begin
               // Always load inputs in S0
               A_ff <= A;
               B_ff <= B;
            end
            S1: begin
               // Computation complete: drive output result
               OUT <= A_ff;
            end
            S2: begin
               // A_ff > B_ff: subtract B_ff from A_ff
               A_ff <= A_ff - B_ff;
            end
            S3: begin
               // B_ff > A_ff: subtract A_ff from B_ff
               B_ff <= B_ff - A_ff;
            end
            default: begin
               A_ff <= '0;
               B_ff <= '0;
               OUT  <= '0;
            end
         endcase
      end
   end

   // Combinational logic: next state and control signal generation
   always_comb begin
      // Default next state assignment
      next_state = S0;
      // Determine equality and greater-than signals based on current state
      if (state == S0) begin
         equal        = (A == B);
         greater_than = (A >  B);
      end else begin
         equal        = (A_ff == B_ff);
         greater_than = (A_ff > B_ff);
      end

      case (state)
         S0: begin
            // Waiting for 'go' signal; if not asserted, remain in S0
            if (!go)
               next_state = S0;
            else if (equal)
               next_state = S1;
            else if (greater_than)
               next_state = S2;
            else
               next_state = S3;
         end
         S1: begin
            // After computation, return to initialization state
            next_state = S0;
         end
         S2: begin
            // In S2, if A_ff equals B_ff then done; else if still greater, stay in S2; otherwise switch to S3
            if (equal)
               next_state = S1;
            else if (greater_than)
               next_state = S2;
            else
               next_state = S3;
         end
         S3: begin
            // In S3, if A_ff equals B_ff then done; else if now A_ff > B_ff switch to S2; otherwise remain in S3
            if (equal)
               next_state = S1;
            else if (greater_than)
               next_state = S2;
            else
               next_state = S3;
         end
         default: begin
            next_state = S0;
         end
      endcase
   end

   // Generate 'done' signal when computation is complete (state S1)
   always_ff @(posedge clk) begin
      if (rst)
         done <= 1'b0;
      else
         done <= (state == S1);
   end

endmodule