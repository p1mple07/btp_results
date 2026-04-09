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

   // Internal signals
   logic equal;                     // Signal indicating A == B
   logic greater_than;              // Signal indicating A > B
   logic controlpath_state;         // Current state of the control FSM

   // Sequential logic for FSM
   always_ff @ (posedge clk) begin
      if (rst) begin
         controlpath_state <= S0;
         A_ff <= 'b0;
         B_ff <= 'b0;
         OUT <= 'b0;
         done <= 1'b0;
      end else begin
         case (controlpath_state)
            S0: begin
                if (!go) begin
                   A_ff <= A;
                   B_ff <= B;
                   equal <= (A == B);
                   greater_than <= (A > B);
                end
                else begin
                   OUT <= A;
                   done <= 1'b0;
                end
            end
            S1: begin
                OUT <= A_ff;
                equal <= (A_ff == B_ff);
                done <= 1'b1;
            end
            S2: begin
                if (greater_than) begin
                   A_ff <= A_ff - B_ff;
                   equal <= (A_ff == B_ff);
                end
            end
            S3: begin
                if (equal) begin
                   A_ff <= B_ff;
                   B_ff <= A_ff - A;
                   equal <= (A_ff == B_ff);
                end
                else begin
                   OUT <= B_ff;
                   done <= 1'b0;
                end
            end
            default: begin
                A_ff <= 'b0;
                B_ff <= 'b0;
                OUT <= 'b0;
                done <= 1'b0;
            end
         endcase
      end
   end

   // Registers
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

endmodule
