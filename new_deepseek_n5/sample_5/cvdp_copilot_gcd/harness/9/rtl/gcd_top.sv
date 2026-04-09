Module for GCD computation for three WIDTH-bit inputs
module gcd_3_ip #(
   parameter WIDTH,
   parameter WIDTH controlpath_state
) (
   input [WIDTH-1:0] A, // First input operand A
   input [WIDTH-1:0] B, // Second input operand B
   input [WIDTH-1:0] C, // Third input operand C
   input clk,                // Clock signal
   input rst,                // Active High Synchronous reset signal
   input go,                 // Start signal to begin GCD calculation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Instantiate first gcd instance to compute GCD(A, B)
   gcd_top gcd1 (.clk(clk), .rst(rst), .A(A), .B(B), .go(g1_go), .equal(e1_eq), .greater_than(g1_gt), .OUT(out1));

   // Instantiate second gcd instance to compute GCD(result1, C)
   gcd_top gcd2 (.clk(clk), .rst(rst), .A(result1), .B(C), .go(g2_go), .equal(e2_eq), .greater_than(g2_gt), .OUT(out2));

   // Instantiate third gcd instance to compute final GCD
   gcd_top gcd3 (.clk(clk), .rst(rst), .A(result2), .B(out2), .go(g3_go), .equal(e3_eq), .greater_than(g3_gt), .OUT(final_out));

   // Control path module for the top level
   control_path gcd_control_path (
      .clk(clk),               // Clock signal
      .rst(rst),               // Active High Synchronous reset signal
      .go(go),                 // Start signal to begin GCD calculation
      .equal(e1_eq, e2_eq, e3_eq),  // Equality signals from datapath
      .greater_than(g1_gt, g2_gt, g3_gt),  // Greater_than signals from datapath
      .controlpath_state (S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3),
      .done(done)               // Signal to indicate completion of computation
   );

   // Instantiate control response signals for the control path
   control_response cr_gcd1_inst (
      .clk(clk),               // Clock signal
      .rst(rst),               // Active High Synchronous reset signal
      .equal(e1_eq),           // Equality signal from datapath
      .greater_than(g1_gt),     // Greater_than signal from datapath
      .controlpath_state (S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3)
   );

   // Instantiate control response signals for the control path
   control_response cr_gcd2_inst (
      .clk(clk),               // Clock signal
      .rst(rst),               // Active High Synchronous reset signal
      .equal(e2_eq),           // Equality signal from datapath
      .greater_than(g2_gt),     // Greater_than signal from datapath
      .controlpath_state (S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3)
   );

   // Instantiate control response signals for the control path
   control_response cr_gcd3_inst (
      .clk(clk),               // Clock signal
      .rst(rst),               // Active High Synchronous reset signal
      .equal(e3_eq),           // Equality signal from datapath
      .greater_than(g3_gt),     // Greater_than signal from datapath
      .controlpath_state (S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3)
   );

   // Instantiate control response signals for the control path
   control_response cr_gcd_top_inst (
      .clk(clk),               // Clock signal
      .rst(rst),               // Active High Synchronous reset signal
      .equal(e1_eq, e2_eq, e3_eq),  // Equality signals from datapath
      .greater_than(g1_gt, g2_gt, g3_gt),  // Greater_than signals from datapath
      .controlpath_state (S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3)
   );

   // Data path module for GCD computation
   gcd_datapath
   #(
      parameter WIDTH,
      // Bit-width of operands
      input [WIDTH-1:0] A,     // Input operand A
      input [WIDTH-1:0] B,     // Input operand B
      input [WIDTH-1:0] C,     // Input operand C
      input [WIDTH-1:0] result, // Output for the GCD result
      output logic              equal,  // Signal indicating A == B
      output logic              greater_than,       // Signal indicating A > B
      output logic  [WIDTH-1:0] OUT   // Output for the GCD result
   ) (
      input [1:0] controlpath_state,  // Current state of the control path
      input [1:0] done               // Output for the done signal
   );

   // State encoding for control signals
   localparam S0 = 2'd0;    // State encoding for A == B
   localparam S1 = 2'd1;    // State encoding for A > B
   localparam S2 = 2'd2;    // State encoding for B > A

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers to zero
         A_ff <= 'b0;
         B_ff <= 'b0;
         equal <= 'b0;
         greater_than <= 'b0;
         done <= 'b0;
      end else begin
         case (controlpath_state)
            S0: begin
               // In state S0: Waiting for 'go' signal to begin GCD computation
               A_ff <= 'b0;
               B_ff <= 'b0;
               equal <= 'b0;
               greater_than <= 'b0;
               done <= 'b0;
            end
            S1: begin
               // In state S1: Computation complete, subtraction B_ff > A_ff
               if (greater_than)
                  A_ff <= A_ff - B_ff;
               else if (equal)
                  A_ff <= A_ff - B_ff;
               else
                  B_ff <= B_ff - A_ff;
               if (A_ff == B_ff)
                  equal <= 1'b1;
               else if (A_ff > B_ff)
                  greater_than <= 1'b1;
               else
                  greater_than <= 1'b0;
               if (rst) begin
                  // On reset, set state to S0
                  controlpath_state <= S0;
               end else begin
                  controlpath_state <= S2;
               end
               done <= 1'b0;
            end
            S2: begin
               // In state S2: Computation complete, subtraction A_ff > B_ff
               if (greater_than)
                  B_ff <= B_ff - A_ff;
               else if (equal)
                  B_ff <= B_ff - A_ff;
               else
                  A_ff <= A_ff - B_ff;
               if (equal)
                  equal <= 1'b1;
               else if (greater_than)
                  greater_than <= 1'b1;
               else
                  greater_than <= 1'b0;
               if (rst) begin
                  // On reset, set state to S0
                  controlpath_state <= S0;
               end else begin
                  controlpath_state <= S0;
               end
               done <= 1'b0;
            end
            default: begin
               // In other states, update the result
               A_ff <= 'b0;
               B_ff <= 'b0;
               equal <= 'b0;
               greater_than <= 'b0;
               done <= 1'b0;
            end
         endcase
      end
   end

   // Control response signals for the control path FSM
   always_comb begin
      case (S0)
         // In state S0: Compare initial input values A and B
         equal        = (A == B)? 1'b1 : 1'b0;
         greater_than = (A > B)? 1'b1 : 1'b0;
      case (S1)
         // In state S1: A_ff > B_ff, subtract B_ff from A_ff
         if (rst)
             equal        = 1'b0;
             greater_than = 1'b0;
         else begin
             equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
             greater_than = (A_ff > B_ff)? 1'b1 : 1'b0;
         end
      case (S2)
         // In state S2: B_ff > A_ff, subtract A_ff from B_ff
         if (rst)
             equal        = 1'b0;
             greater_than = 1'b0;
         else begin
             equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
             greater_than = (A_ff > B_ff)? 1'b1 : 1'b0;
         end
      default:
         equal        = 1'b0;
         greater_than = 1'b0;
   endcase
endmodule