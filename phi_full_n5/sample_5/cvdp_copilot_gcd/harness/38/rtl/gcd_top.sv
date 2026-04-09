module gcd_top #(
   parameter WIDTH = 4
) (
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset
   input                     go,    // Start GCD computation
   input                     [WIDTH-1:0] A,     // Input operand A
   input                     [WIDTH-1:0] B,     // Input operand B
   output logic             [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic             done       // Signal to indicate completion of computation
);

   // Internal signals for FSM
   logic [1:0] fsm_state;
   logic equal;
   logic greater_than;

   // FSM state encoding
   localparam S0 = 2'd0;    // Initialization or waiting for 'go'
   localparam S1 = 2'd1;    // A_ff == B_ff, comparison done
   localparam S2 = 2'd2;    // A_ff > B_ff
   localparam S3 = 2'd3;    // B_ff > A_ff

   // FSM logic
   always_ff @(posedge clk or negedge rst) begin
      if (rst) begin
         fsm_state <= S0;
         OUT <= 'b0;
         done <= 1'b0;
      end else begin
         case (fsm_state)
            S0: begin
                if (!go) begin
                   OUT <= 'b0;
                   done <= 1'b0;
                end
                if (go) begin
                   fsm_state <= S1;
                end
             end
            S1: begin
                equal = (A == B);
                greater_than = (A > B);
                if (equal) begin
                   OUT <= A;
                   done <= 1'b1;
                end
                if (greater_than) begin
                   fsm_state <= S2;
                end
             end
            S2: begin
                if (equal) begin
                   fsm_state <= S1;
                end
                if (!equal & !greater_than) begin
                   OUT <= A - B;
                   fsm_state <= S3;
                end
             end
            S3: begin
                if (equal) begin
                   fsm_state <= S1;
                end
                if (greater_than) begin
                   fsm_state <= S2;
                end
                if (equal) begin
                   OUT <= A;
                   done <= 1'b1;
                end
             end
            default: begin
                OUT <= 'b0;
                done <= 1'b0;
                fsm_state <= S0;
            end
         endcase
      end
   end

endmodule
