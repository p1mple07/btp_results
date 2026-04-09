module gcd_3_ip #(parameter WIDTH = 4) (
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset
   input                     go,    // Start signal
   input [WIDTH-1:0]        A,     // Input operand A
   input [WIDTH-1:0]        B,     // Input operand B
   input [WIDTH-1:0]        C,     // Input operand C
   input                     go_final, // Start signal for final GCD calculation
   output logic [WIDTH-1:0] OUT_FINAL, // Output for the final GCD result
   output logic              done_final  // Signal to indicate completion of final GCD computation
);

   // Instantiate the first pair of gcd_top modules
   gcd_top gcd_top1_inst1 (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .go                (go),                // Connect start signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .go_final          (1'b0),               // Start signal for first GCD calculation
      .OUT_FINAL         (gcd_top1_out),      // Connect output for first GCD result
      .done_final        (gcd_top1_done)       // Connect done signal for first GCD calculation
   );

   gcd_top gcd_top2_inst1 (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .go                (1'b0),               // Start signal for second GCD calculation
      .B                 (B),                 // Connect input B
      .C                 (C),                 // Connect input C
      .go_final          (go),                 // Connect start signal for second GCD calculation
      .OUT_FINAL         (gcd_top2_out),      // Connect output for second GCD result
      .done_final        (gcd_top2_done)       // Connect done signal for second GCD calculation
   );

   // Instantiate the final gcd_top module
   gcd_top gcd_top3_inst1 (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .go                (go_final),          // Connect start signal for final GCD calculation
      .A                 (gcd_top1_out),     // Connect output from first GCD calculation
      .B                 (gcd_top2_out),     // Connect output from second GCD calculation
      .OUT_FINAL         (OUT_FINAL),         // Connect output for final GCD result
      .done_final        (done_final)          // Connect done signal for final GCD computation
   );

endmodule

// Instantiate the gcd_top module for GCD computation
module gcd_top (
   input                     clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input                     go,                 // Start signal
   input                     go_final,           // Start signal for final GCD calculation
   input [WIDTH-1:0]        A,                  // Input operand A
   input [WIDTH-1:0]        B,                  // Input operand B
   input [WIDTH-1:0]        gcd_top1_out,       // Output GCD result from first calculation
   input [WIDTH-1:0]        gcd_top2_out,       // Output GCD result from second calculation
   output logic [WIDTH-1:0] OUT_FINAL,          // Output for the final GCD result
   output logic              done_final          // Signal indicating final GCD computation completion
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers to zero
         A_ff <= 'b0;
         B_ff <= 'b0;
         OUT_FINAL <= 'b0;
      end else begin
         case (controlpath_state)
            S0: begin
                // In state S0, load input values into registers
                A_ff <= A;
                B_ff <= B;
             end
            S1: begin
                // In state S1, computation is done, output the result
                OUT_FINAL <= gcd_top1_out;
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
                OUT_FINAL <= 'b0;
            end
         endcase
      end
   end

   // Generating control response signals for the control path FSM
   always_comb begin
      case(controlpath_state)
         S0: begin
            // In state S0, compare initial input values A and B
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A > B)? 1'b1 : 1'b0;
          end
          default: begin
            // In other states, compare the current values in registers A_ff and B_ff
            equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
            greater_than = (A_ff > B_ff)? 1'b1 : 1'b0;
          end
      endcase
   end

   // Control path module for GCD computation FSM
module gcd_controlpath (
   input                    clk,               // Clock signal
   input                    rst,               // Active High Synchronous reset
   input                    go,                // Start GCD calculation signal
   input                    equal,             // From datapath: A_ff equals B_ff
   input                    greater_than,      // From datapath: A_ff is greater than B_ff
   output logic [1:0]       controlpath_state, // Current state to datapath
   output logic             done               // Indicates completion of GCD calculation
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [1:0] next_state;  // Next state of FSM

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff

   // State latching logic: Update current state on clock edge
   always_ff @ (posedge clk) begin
      if (rst) begin
         curr_state   <= S0;   // On reset, set state to S0
      end else begin
         curr_state   <= next_state;   // Transition to next state
      end
   end

   // State transition logic: Determine next state based on current state and inputs
   always_comb begin
      case(curr_state)
         S0: begin
            // State S0: Waiting for 'go' signal
            if(!go)
                next_state = S0;         // Remain in S0 until 'go' is asserted
            else if (equal)
                next_state = S1;         // If A == B, computation is complete
            else if (greater_than)
                next_state = S2;         // If A > B, go to state S2
            else
                next_state = S3;         // If B > A, go to state S3
         end
         S1: begin
             // State S1: Computation complete, output the result
             next_state = S0;           // Return to S0 after completion
         end
         S2: begin
             // State S2: A_ff > B_ff, subtract B_ff from A_ff
             if(equal)
                next_state = S1;         // If A_ff == B_ff after subtraction, go to S1
             else if (greater_than)
                next_state = S2;         // If A_ff > B_ff, stay in S2
             else
                next_state = S3;         // If B_ff > A_ff, go to S3
         end
         S3: begin
             // State S3: B_ff > A_ff, subtract A_ff from B_ff
             if (equal)
                next_state = S1;         // If A_ff == B_ff after subtraction, go to S1
             else if (greater_than)
                next_state = S2;         // If A_ff > B_ff, go to S2
             else
                next_state = S3;         // If B_ff > A_ff, stay in S3
         end
         default: begin
             next_state = S0;
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

endmodule
