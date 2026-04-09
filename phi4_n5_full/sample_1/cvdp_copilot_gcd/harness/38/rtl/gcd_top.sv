module gcd_top #(
   parameter WIDTH = 4              // Bit-width of the input and output data
)(
   input                     clk,   // Clock signal
   input                     rst,   // Active high synchronous reset
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input                     go,    // Start signal for GCD computation
   output logic [WIDTH-1:0]  OUT,   // GCD result
   output logic              done   // Computation complete indicator
);

   // Internal registers for holding intermediate values
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;
   // FSM state registers and encoding
   logic [1:0] state, next_state;
   localparam S0 = 2'd0;    // Initialization: load inputs
   localparam S1 = 2'd1;    // Computation complete: result ready
   localparam S2 = 2'd2;    // A_ff > B_ff: subtract B_ff from A_ff
   localparam S3 = 2'd3;    // B_ff > A_ff: subtract A_ff from B_ff

   // Combinational logic for next state and comparison signals
   // In state S0, comparisons use the original inputs; otherwise, use A_ff and B_ff.
   logic equal, greater_than;
   always_comb begin
      if (state == S0) begin
         equal        = (A == B);
         greater_than = (A >  B);
      end else begin
         equal        = (A_ff == B_ff);
         greater_than = (A_ff >  B_ff);
      end

      case (state)
         S0: begin
            // Wait for 'go' signal; if not asserted, remain in S0.
            if (!go)
               next_state = S0;
            else if (equal)
               next_state = S1;          // Equal: computation done
            else if (greater_than)
               next_state = S2;          // A > B: subtract B from A
            else
               next_state = S3;          // B > A: subtract A from B
         end
         S1: begin
            next_state = S0;             // After completion, return to initialization
         end
         S2: begin
            if (equal)
               next_state = S1;          // Subtraction resulted in equality
            else if (greater_than)
               next_state = S2;          // Remain in subtraction state if A_ff > B_ff
            else
               next_state = S3;          // Otherwise, switch to subtracting A_ff from B_ff
         end
         S3: begin
            if (equal)
               next_state = S1;          // Subtraction resulted in equality
            else if (greater_than)
               next_state = S2;          // Switch to subtracting B_ff from A_ff if needed
            else
               next_state = S3;          // Remain in current subtraction state
         end
         default: next_state = S0;
      endcase
   end

   // Single FSM sequential block combining control and datapath logic.
   always_ff @(posedge clk) begin
      if (rst) begin
         state <= S0;
         A_ff  <= '0;
         B_ff  <= '0;
         OUT   <= '0;
      end else begin
         // Datapath update based on current state
         case (state)
            S0: begin
               // Load the inputs into registers
               A_ff <= A;
               B_ff <= B;
            end
            S1: begin
               // Output the result when computation is complete
               OUT <= A_ff;
            end
            S2: begin
               // In state S2, subtract B_ff from A_ff if A_ff > B_ff
               if (A_ff > B_ff)
                  A_ff <= A_ff - B_ff;
            end
            S3: begin
               // In state S3, subtract A_ff from B_ff if B_ff > A_ff
               if (A_ff < B_ff)
                  B_ff <= B_ff - A_ff;
            end
         endcase
         // Update FSM state based on combinational next_state logic
         state <= next_state;
      end
   end

   // 'done' signal is asserted when state is S1 (computation complete)
   assign done = (state == S1);

endmodule