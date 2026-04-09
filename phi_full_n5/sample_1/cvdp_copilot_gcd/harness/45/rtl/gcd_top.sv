module gcd_top #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input                     go,
   input                     equal,
   input [WIDTH-1:0]        A,
   input [WIDTH-1:0]        B,
   output logic [WIDTH-1:0] OUT,
   output logic             done
);

   // Combined FSM states
   localparam S0 = 2'd0; // Idle/Load
   localparam S1 = 2'd1; // Computing
   localparam S2 = 2'd2; // Done

   // FSM registers
   logic [1:0] fsm_state, next_state;
   logic [WIDTH-1:0] A_ff, B_ff, OUT_ff;
   logic [WIDTH-1:0] diff, gcd_val;
   logic both_even, a_even, b_even;

   // Combinational logic for FSM
   always_comb begin
      // Determine next state based on current state and inputs
      case (fsm_state)
         S0: begin
            next_state = go ? S1 : S0;
         end
         S1: begin
            // Check if both A and B are zero
            if (A_ff == 'b0 && B_ff == 'b0) begin
               next_state = S2;
               OUT_ff = 'b0;
               diff = 'b0;
            end else begin
               // Compute the next values
               next_A_ff = A_ff >> 1;
               next_B_ff = B_ff >> 1;
               next_OUT_ff = (A_ff == B_ff) ? gcd_val : A_ff - B_ff;
               diff = (A_ff == B_ff) ? 'b0 : (A_ff > B_ff) ? A_ff - B_ff : B_ff - A_ff;
            end
         end
         S2: begin
            // Check if equal, move to done state
            next_state = equal ? S1 : S2;
         end
         default: begin
            next_state = S0;
         end
      endcase
   end

   // Sequential logic for FSM
   always_ff @(posedge clk) begin
      if (rst) begin
         fsm_state <= S0;
         A_ff      <= 'b0;
         B_ff      <= 'b0;
         OUT_ff    <= 'b0;
      end else begin
         fsm_state <= next_state;
         A_ff      <= next_A_ff;
         B_ff      <= next_B_ff;
         OUT_ff    <= next_OUT_ff;
         diff      <= diff;
         gcd_val   <= (A_ff == B_ff) ? gcd_val : gcd_val;
      end
   end

   // Output assignment
   assign OUT = OUT_ff;
   assign done = (fsm_state == S2);

endmodule
