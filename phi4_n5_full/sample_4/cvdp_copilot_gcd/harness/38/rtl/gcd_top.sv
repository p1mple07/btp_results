module gcd_top #(
   parameter WIDTH = 4  // Bit-width of input and output data
)(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input                     go,    // Start signal for GCD computation
   output logic [WIDTH-1:0]  OUT,   // GCD result output
   output logic              done   // Computation complete indicator
);

   // Local state encoding for the combined FSM
   localparam S0 = 2'd0;    // Initialization/wait state: waiting for 'go'
   localparam S1 = 2'd1;    // Computation complete: result valid
   localparam S2 = 2'd2;    // A_ff > B_ff: subtract B_ff from A_ff
   localparam S3 = 2'd3;    // B_ff > A_ff: subtract A_ff from B_ff

   // Registers for internal datapath values and state
   logic [1:0] state;       // FSM state register
   logic [WIDTH-1:0] A_ff;  // Registered copy of input A
   logic [WIDTH-1:0] B_ff;  // Registered copy of input B

   // Combined FSM integrating control and datapath logic.
   // This block replaces the separate control and datapath modules,
   // thereby reducing interconnect complexity (wires) and cell count.
   always_ff @(posedge clk) begin
      if (rst) begin
         state   <= S0;
         A_ff    <= '0;
         B_ff    <= '0;
         OUT     <= '0;
      end else begin
         case (state)
            S0: begin
               // Wait for the 'go' signal. When asserted, load inputs.
               if (go) begin
                  A_ff <= A;
                  B_ff <= B;
                  // Use the original inputs for comparison in S0.
                  if (A == B)
                     state <= S1;    // If equal, result is ready.
                  else if (A > B)
                     state <= S2;    // If A > B, prepare to subtract B from A.
                  else
                     state <= S3;    // Otherwise, B > A; prepare to subtract A from B.
               end else begin
                  state <= S0;        // Remain idle until 'go' is asserted.
               end
            end
            S1: begin
               // Computation complete: output the result and return to idle.
               OUT  <= A_ff;
               state <= S0;
            end
            S2: begin
               // In state S2, A_ff > B_ff: subtract B_ff from A_ff.
               if (A_ff > B_ff) begin
                  A_ff <= A_ff - B_ff;
                  state <= S2;
               end else if (A_ff == B_ff) begin
                  state <= S1;
               end else begin
                  state <= S3;
               end
            end
            S3: begin
               // In state S3, B_ff > A_ff: subtract A_ff from B_ff.
               if (B_ff > A_ff) begin
                  B_ff <= B_ff - A_ff;
                  state <= S3;
               end else if (A_ff == B_ff) begin
                  state <= S1;
               end else begin
                  state <= S2;
               end
            end
            default: begin
               state <= S0;
            end
         endcase
      end
   end

   // Generate the 'done' signal when the computation is complete.
   assign done = (state == S1);

endmodule