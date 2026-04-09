module gcd_top #(
   parameter WIDTH = 4              // Bit-width of the input and output data
)(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // State encoding for the combined FSM
   localparam S0 = 2'd0;    // Initialization/wait state
   localparam S1 = 2'd1;    // Computation complete
   localparam S2 = 2'd2;    // A_ff > B_ff: subtract B_ff from A_ff
   localparam S3 = 2'd3;    // B_ff > A_ff: subtract A_ff from B_ff

   // Internal registers for datapath and FSM
   logic [1:0] state;
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // Combined sequential logic: FSM and datapath
   always_ff @(posedge clk) begin
      if (rst) begin
         state  <= S0;
         A_ff   <= '0;
         B_ff   <= '0;
         OUT    <= '0;
      end else begin
         case (state)
            S0: begin
               // Wait for the go signal; when asserted, load inputs
               if (go) begin
                  A_ff <= A;
                  B_ff <= B;
               end
               // Transition from S0 based on the initial comparison of A and B
               if (go)
                  state <= (A == B) ? S1 : ((A > B) ? S2 : S3);
               else
                  state <= S0;
            end
            S1: begin
               // Computation complete: capture the result
               OUT <= A_ff;
               state <= S0;  // Return to wait state for a new computation
            end
            S2: begin
               // In state S2: A_ff > B_ff, subtract B_ff from A_ff
               if (A_ff > B_ff)
                  A_ff <= A_ff - B_ff;
               // Update state based on the new values of A_ff and B_ff
               if (A_ff == B_ff)
                  state <= S1;
               else if (A_ff > B_ff)
                  state <= S2;
               else
                  state <= S3;
            end
            S3: begin
               // In state S3: B_ff > A_ff, subtract A_ff from B_ff
               if (B_ff > A_ff)
                  B_ff <= B_ff - A_ff;
               // Update state based on the new values of A_ff and B_ff
               if (A_ff == B_ff)
                  state <= S1;
               else if (A_ff > B_ff)
                  state <= S2;
               else
                  state <= S3;
            end
            default: begin
               state <= S0;
            end
         endcase
      end
   end

   // Generate the done signal when computation is complete
   always_ff @(posedge clk) begin
      if (rst)
         done <= 1'b0;
      else
         done <= (state == S1);
   end

endmodule