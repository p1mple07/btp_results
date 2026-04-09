module gcd_top #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
) (
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Internal signals to communicate between FSM states and datapath
   logic equal;                     // Signal indicating A == B
   logic greater_than;              // Signal indicating A > B
   logic [1:0] controlpath_state;   // Current state of the control FSM
   logic [WIDTH-1:0] A_ff, B_ff;    // Registers to hold intermediate values of A and B

   // FSM and datapath logic combined
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize state and registers
         controlpath_state <= S0;
         A_ff <= 'b0;
         B_ff <= 'b0;
         OUT <= 'b0;
         done <= 1'b0;
      end else begin
         // State encoding for control signals
         case (controlpath_state)
            S0: begin
                equal <= (A == B);
                greater_than <= (A > B);
                // In state S0, load input values into registers
                A_ff <= A;
                B_ff <= B;
             end
            S1: begin
                // In state S1, computation is done, output the result
                OUT <= A_ff;
                // Generate 'done' signal
                done <= 1'b1;
             end
            S2: begin
                // In state S2, A_ff > B_ff, subtract B_ff from A_ff
                if (greater_than)
                   A_ff <= A_ff - B_ff;
                // Transition to S1 if A_ff equals B_ff
                if (equal)
                   controlpath_state <= S1;
             end
            S3: begin
                // In state S3, B_ff > A_ff, subtract A_ff from B_ff
                if (!equal & !greater_than)
                   B_ff <= B_ff - A_ff;
                // Transition to S1 if B_ff equals A_ff
                if (equal)
                   controlpath_state <= S1;
             end
            default: begin
                // In other states, compare the current values in registers A_ff and B_ff
                equal <= (A_ff == B_ff);
                greater_than <= (A_ff > B_ff);
                // Transition to S0 if A_ff equals B_ff
                if (equal)
                   controlpath_state <= S0;
             end
         endcase
      end
   end

endmodule
