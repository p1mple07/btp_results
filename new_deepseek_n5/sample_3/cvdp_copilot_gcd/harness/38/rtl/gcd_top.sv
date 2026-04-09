module gcd_top #(
   parameter WIDTH = 4
   )(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // FSM state encoding
   localparam S0 = 2'd0;    // Initialization state
   localparam S1 = 2'd1;    // Computation complete
   localparam S2 = 2'd2;    // A > B, subtract B from A
   localparam S3 = 2'd3;    // B > A, subtract A from B

   // FSM state register
   logic [1:0] curr_state;

   // Register to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // Sequential logic to update registers based on state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers to zero
         A_ff <= 'b0;
         B_ff <= 'b0;
         curr_state <= S0;
      end else begin
         case (curr_state)
            S0: begin
               // Load input values into registers
               A_ff <= A;
               B_ff <= B;
            end
            S1: begin
               // Computation complete, output the result
               OUT  <= A_ff;
            end
            S2: begin
               // A > B, subtract B from A
               if (A_ff > B_ff)
                  A_ff <= A_ff - B_ff;
            end
            S3: begin
               // B > A, subtract A from B
               if (B_ff > A_ff)
                  B_ff <= B_ff - A_ff;
            end
            default: begin
               A_ff <= 'b0;
               B_ff <= 'b0;
               curr_state <= S0;
            end
         endcase
      end
   end

   // Generate control response signals for FSM
   always_comb begin
      case(curr_state)
         S0: begin
            // In initialization state
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A > B)? 1'b1 : 1'b0;
         end
         S1: begin
            // In computation complete state
            equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
            greater_than = (A_ff > B_ff)? 1'b1 : 1'b0;
         end
         S2: begin
            // A > B state
            if (A_ff > B_ff)
               greater_than = 1'b1;
            else
               equal = 1'b1;
         end
         S3: begin
            // B > A state
            if (B_ff > A_ff)
               greater_than = 1'b1;
            else
               equal = 1'b1;
         end
         default: begin
            equal        = 1'b0;
            greater_than = 1'b0;
         end
      endcase
   end

   // Output logic: Generate 'done' signal when computation is complete
   always_ff @ (posedge clk) begin
     if(rst) begin
        done <= 1'b0;             // On reset, 'done' is low
     end else begin
        done <= (curr_state == S1); // 'done' is asserted when in state S1
     end
   end

   // Assign current state to output for FSM
   assign curr_state = curr_state;

endmodule