module gcd_top #(
   parameter WIDTH = 4
   )(
   input                     clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input  [WIDTH-1:0]        A,                  // Input operand A
   input  [WIDTH-1:0]        B,                  // Input operand B
   input  [1:0]              controlpath_state,  // Current state from control path
   output logic              equal,              // Signal indicating A_ff == B_ff
   output logic              greater_than,       // Signal indicating A_ff > B_ff
   output logic  [WIDTH-1:0] OUT                 // Output GCD result
);

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff, subtract B_ff from A_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff, subtract A_ff from B_ff

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [1:0] next_state;  // Next state of FSM

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers to zero
         A_ff <= 'b0;
         B_ff <= 'b0;
         OUT  <= 'b0;
      end else begin
         case (controlpath_state)
            S0: begin
               // In state S0, load input values into registers
               A_ff <= A;
               B_ff <= B;
            end
            S1: begin
               // In state S1, computation is done, output the result
               OUT  <= A_ff;
            end
            S2: begin
               // In state S2, A_ff > B_ff, subtract B_ff from A_ff
               if (greater_than)
                  A_ff <= A_ff - B_ff;
            end
            S3: begin
               // In state S3, B_ff > A_ff, subtract A_ff from B_ff
               if (!equal & !greater_than)
                  B_ff <= B_ff - A_ff;
            end
            default: begin
               A_ff <= 'b0;
               B_ff <= 'b0;
               OUT <= 'b0;
            end
         endcase
      end
   end

   // Generating control response signals for the control path FSM
   always_comb begin
      case(curr_state)
         S0: begin
            // In state S0, compare initial input values A and B
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A >  B)? 1'b1 : 1'b0;
          end
          default: begin
            // In other states, compare the current values in registers A_ff and B_ff
            equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
            greater_than = (A_ff >  B_ff)? 1'b1 : 1'b0;
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

   // Assign current state to output for datapath
   assign controlpath_state = curr_state;

   // Datapath registers
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;
endmodule