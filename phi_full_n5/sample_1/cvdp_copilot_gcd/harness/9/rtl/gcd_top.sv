module gcd_3_ip #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
   )(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input  [WIDTH-1:0]        C,     // Input operand C
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Instantiate the first pair of inputs GCD top module
   gcd_top gcd_top_1_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .go                (go),                // Connect go signal
      .OUT               (gcd_top_1_OUT),   // Connect GCD result to output
      .done              (gcd_top_1_done)    // Connect done signal
   );

   // Instantiate the second pair of inputs GCD top module
   gcd_top gcd_top_2_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (B),                 // Connect input B
      .B                 (C),                 // Connect input C
      .go                (go),                // Connect go signal
      .OUT               (gcd_top_2_OUT),   // Connect GCD result to output
      .done              (gcd_top_2_done)    // Connect done signal
   );

   // Instantiate the final GCD calculation module
   gcd_top gcd_top_3_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (gcd_top_1_OUT),   // Connect GCD result from gcd_top_1 to input
      .B                 (gcd_top_2_OUT),   // Connect GCD result from gcd_top_2 to input
      .go                (go),                // Connect go signal
      .OUT               (OUT),               // Connect final GCD result to output
      .done              (done)               // Connect done signal
   );

   // Latching control signals
   always_ff @ (posedge clk) begin
      if (rst) begin
         gcd_top_1_done <= 1'b0;
         gcd_top_2_done <= 1'b0;
      end else begin
         gcd_top_1_done <= (gcd_top_1_OUT == OUT) & (gcd_top_1_done == 1'b0);
         gcd_top_2_done <= (gcd_top_2_OUT == OUT) & (gcd_top_2_done == 1'b0);
      end
   end

endmodule

module gcd_top #(
   parameter WIDTH = 4
   )(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input                     go,
   output logic  [WIDTH-1:0] OUT,
   output logic              done
);

   // Instantiate the control path module
   gcd_controlpath gcd_controlpath_inst (
      .clk               (clk),
      .rst               (rst),
      .go                (go),
      .equal             (equal),
      .greater_than      (greater_than),
      .controlpath_state (controlpath_state),
      .done              (done)
   );

   // Instantiate the data path module
   gcd_datapath
   #( .WIDTH(WIDTH)
   ) gcd_datapath_inst (
      .clk               (clk),
      .rst               (rst),
      .A                 (A),
      .B                 (B),
      .controlpath_state (controlpath_state),
      .equal             (equal),
      .greater_than      (greater_than),
      .OUT               (OUT)
   );

endmodule

module gcd_controlpath (
   input                    clk,
   input                    rst,
   input                    go,
   input                    equal,
   input                    greater_than,
   output logic [1:0]       controlpath_state,
   output logic             done
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

module gcd_datapath  #(
   parameter WIDTH = 4
   )(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input  [1:0]              controlpath_state,
   output logic              equal,
   output logic              greater_than,
   output logic  [WIDTH-1:0] OUT
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization state
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers to zero
         A_ff <= 'b0;
         B_ff <= 'b0;
      end else begin
         case (controlpath_state)
            S0: begin
                // In state S0, load input values into registers
                A_ff <= A;
                B_ff <= B;
             end
            S1: begin
                // In state S1, computation is done, output the result
                OUT <= A_ff;
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
      case(controlpath_state)
         S0: begin
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A >  B)? 1'b1 : 1'b0;
          end
          default: begin
            equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
            greater_than = (A_ff >  B_ff)? 1'b1 : 1'b0;
          end
      endcase
   end
endmodule
 module gcd_3_ip #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
   )(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input  [WIDTH-1:0]        C,     // Input operand C
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Instantiate the first pair of inputs GCD top module
   gcd_top gcd_top_1_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .go                (go),                // Connect go signal
      .OUT               (gcd_top_1_OUT),   // Connect GCD result to output
      .done              (gcd_top_1_done)    // Connect done signal
   );

   // Instantiate the second pair of inputs GCD top module
   gcd_top gcd_top_2_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (B),                 // Connect input B
      .B                 (C),                 // Connect input C
      .go                (go),                // Connect go signal
      .OUT               (gcd_top_2_OUT),   // Connect GCD result to output
      .done              (gcd_top_2_done)    // Connect done signal
   );

   // Instantiate the final GCD calculation module
   gcd_top gcd_top_3_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (gcd_top_1_OUT),   // Connect GCD result from gcd_top_1 to input
      .B                 (gcd_top_2_OUT),   // Connect GCD result from gcd_top_2 to input
      .go                (go),                // Connect go signal
      .OUT               (OUT),               // Connect final GCD result to output
      .done              (done)               // Connect done signal
   );

   // Latching control signals
   always_ff @ (posedge clk) begin
      if (rst) begin
         gcd_top_1_done <= 1'b0;
         gcd_top_2_done <= 1'b0;
      end else begin
         gcd_top_1_done <= (gcd_top_1_OUT == OUT) & (gcd_top_1_done == 1'b0);
         gcd_top_2_done <= (gcd_top_2_OUT == OUT) & (gcd_top_2_done == 1'b0);
      end
   end

endmodule

module gcd_controlpath (
   input                    clk,
   input                    rst,
   input                    go,
   input                    equal,
   input                    greater_than,
   output logic [1:0]       controlpath_state,
   output logic             done
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

module gcd_datapath  #(
   parameter WIDTH = 4
   )(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input  [1:0]              controlpath_state,
   output logic              equal,
   output logic              greater_than,
   output logic  [WIDTH-1:0] OUT
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization state
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers to zero
         A_ff <= 'b0;
         B_ff <= 'b0;
      end else begin
         case (controlpath_state)
            S0: begin
                // In state S0, load input values into registers
                A_ff <= A;
                B_ff <= B;
             end
            S1: begin
                // In state S1, computation is done, output the result
                OUT <= A_ff;
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
      case(controlpath_state)
         S0: begin
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A >  B)? 1'b1 : 1'b0;
          end
          default: begin
            equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
            greater_than = (A_ff >  B_ff)? 1'b1 : 1'b0;
          end
      endcase
   end
endmodule
 module gcd_3_ip #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
   )(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input  [WIDTH-1:0]        C,     // Input operand C
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Instantiate the first pair of inputs GCD top module
   gcd_top gcd_top_1_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .go                (go),                // Connect go signal
      .OUT               (gcd_top_1_OUT),   // Connect GCD result to output
      .done              (gcd_top_1_done)    // Connect done signal
   );

   // Instantiate the second pair of inputs GCD top module
   gcd_top gcd_top_2_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (B),                 // Connect input B
      .B                 (C),                 // Connect input C
      .go                (go),                // Connect go signal
      .OUT               (gcd_top_2_OUT),   // Connect GCD result to output
      .done              (gcd_top_2_done)    // Connect done signal
   );

   // Instantiate the final GCD calculation module
   gcd_top gcd_top_3_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (gcd_top_1_OUT),   // Connect GCD result from gcd_top_1 to input
      .B                 (gcd_top_2_OUT),   // Connect GCD result from gcd_top_2 to input
      .go                (go),                // Connect go signal
      .OUT               (OUT),               // Connect final GCD result to output
      .done              (done)               // Connect done signal
   );

   // Latching control signals
   always_ff @ (posedge clk) begin
      if (rst) begin
         gcd_top_1_done <= 1'b0;
         gcd_top_2_done <= 1'b0;
      end else begin
         gcd_top_1_done <= (gcd_top_1_OUT == OUT) & (gcd_top_1_done == 1'b0);
         gcd_top_2_done <= (gcd_top_2_OUT == OUT) & (gcd_top_2_done == 1'b0);
      end
   end

endmodule

module gcd_controlpath (
   input                    clk,
   input                    rst,
   input                    go,
   input                    equal,
   input                    greater_than,
   output logic [1:0]       controlpath_state,
   output logic             done
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

module gcd_datapath  #(
   parameter WIDTH = 4
   )(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input  [1:0]              controlpath_state,
   output logic              equal,
   output logic              greater_than,
   output logic  [WIDTH-1:0] OUT
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization state
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers to zero
         A_ff <= 'b0;
         B_ff <= 'b0;
      end else begin
         case (controlpath_state)
            S0: begin
                // In state S0, load input values into registers
                A_ff <= A;
                B_ff <= B;
             end
            S1: begin
                // In state S1, computation is done, output the result
                OUT <= A_ff;
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
      case(controlpath_state)
         S0: begin
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A >  B)? 1'b1 : 1'b0;
          end
          default: begin
            equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
            greater_than = (A_ff >  B_ff)? 1'b1 : 1'b0;
          end
      endcase
   end
endmodule
 module gcd_3_ip #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
   )(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input  [WIDTH-1:0]        C,     // Input operand C
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Instantiate the first pair of inputs GCD top module
   gcd_top gcd_top_1_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .go                (go),                // Connect go signal
      .OUT               (gcd_top_1_OUT),   // Connect GCD result to output
      .done              (gcd_top_1_done)    // Connect done signal
   );

   // Instantiate the second pair of inputs GCD top module
   gcd_top gcd_top_2_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (B),                 // Connect input B
      .B                 (C),                 // Connect input C
      .go                (go),                // Connect go signal
      .OUT               (gcd_top_2_OUT),   // Connect GCD result to output
      .done              (gcd_top_2_done)    // Connect done signal
   );

   // Instantiate the final GCD calculation module
   gcd_top gcd_top_3_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (gcd_top_1_OUT),   // Connect GCD result from gcd_top_1 to input
      .B                 (gcd_top_2_OUT),   // Connect GCD result from gcd_top_2 to input
      .go                (go),                // Connect go signal
      .OUT               (OUT),               // Connect final GCD result to output
      .done              (done)               // Connect done signal
   );

   // Latching control signals
   always_ff @ (posedge clk) begin
      if (rst) begin
         gcd_top_1_done <= 1'b0;
         gcd_top_2_done <= 1'b0;
      end else begin
         gcd_top_1_done <= (gcd_top_1_OUT == OUT) & (gcd_top_1_done == 1'b0);
         gcd_top_2_done <= (gcd_top_2_OUT == OUT) & (gcd_top_2_done == 1'b0);
      end
   end

endmodule

module gcd_controlpath (
   input                    clk,
   input                    rst,
   input                    go,
   input                    equal,
   input                    greater_than,
   output logic [1:0]       controlpath_state,
   output logic             done
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

module gcd_datapath  #(
   parameter WIDTH = 4
   )(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input  [1:0]              controlpath_state,
   output logic              equal,
   output logic              greater_than,
   output logic  [WIDTH-1:0] OUT
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization state
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers to zero
         A_ff <= 'b0;
         B_ff <= 'b0;
      end else begin
         case (controlpath_state)
            S0: begin
                // In state S0, load input values into registers
                A_ff <= A;
                B_ff <= B;
             end
            S1: begin
                // In state S1, computation is done, output the result
                OUT <= A_ff;
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
      case(controlpath_state)
         S0: begin
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A >  B)? 1'b1 : 1'b0;
          end
          default: begin
            equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
            greater_than = (A_ff >  B_ff)? 1'b1 : 1'b0;
          end
      endcase
   end
endmodule
 module gcd_3_ip #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
   )(
   input clk,                   // Clock signal
   input rst,                  // Active High Synchronous reset signal
   input [WIDTH-1:0] A,           // Input operand A
   input [WIDTH-1:0] B,           // Input operand B
   input [WIDTH-1:0] C,           // Input operand C
   input go,                   // Start signal to begin GCD computation
   output [WIDTH-1:0] OUT,         // Output for the GCD result
   output done                // Signal to indicate completion of computation
);

   // Instantiate the first pair of inputs GCD top module
   gcd_top gcd_top_1_inst (
      clk,                     // Connect clock signal
      rst,                    // Connect reset signal
      A,                      // Connect input A
      B,                      // Connect input B
      go,                     // Connect go signal
      gcd_top_1_OUT,          // Connect GCD result to output
      gcd_top_1_done          // Connect done signal
   );

   // Instantiate the second pair of inputs GCD top module
   gcd_top gcd_top_2_inst (
      clk,                     // Connect clock signal
      rst,                    // Connect reset signal
      B,                      // Connect input B
      C,                      // Connect input C
      go,                     // Connect go signal
      gcd_top_2_OUT,          // Connect GCD result to output
      gcd_top_2_done          // Connect done signal
   );

   // Instantiate the final GCD calculation module
   gcd_top gcd_top_3_inst (
      clk,                     // Connect clock signal
      rst,                    // Connect reset signal
      gcd_top_1_OUT,          // Connect GCD result from gcd_top_1 to input
      gcd_top_2_OUT,          // Connect GCD result from gcd_top_2 to input
      go,                     // Connect go signal
      OUT,                    // Connect final GCD result to output
      done                    // Connect done signal
   );

   // Latching control signals
   always_ff @(posedge clk) begin
      if (rst) begin
         done <= 1'b0;             // On reset, 'done' is low
         gcd_top_1_done <= 1'b0;
         gcd_top_2_done <= 1'b0;
      end else begin
         done <= (curr_state == S1); // 'done' is asserted when in state S1
         gcd_top_1_done <= (gcd_top_1_OUT == OUT) & (gcd_top_1_done == 1'b0);
         gcd_top_2_done <= (gcd_top_2_OUT == OUT) & (gcd_top_2_done == 1'b0);
      end
   end

   // FSM state logic for gcd_controlpath
   always_comb begin
      case(curr_state)
         S0: begin
            next_state = curr_state;         // Remain in S0 until 'go' is asserted
         end
         S1: begin
            next_state = S0;               // Return to S0 after completion
         end
         S2: begin
            next_state = S1;               // Return to S1 after subtraction
         end
         S3: begin
            next_state = S2;               // Return to S2 after subtraction
         end
         default: begin
            next_state = S0;
         end
      endcase
   end

   // FSM state logic for gcd_datapath
   always_comb begin
      case(controlpath_state)
         S0: begin
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A > B)? 1'b1 : 1'b0;
         end
         S1: begin
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A > B)? 1'b1 : 1'b0;
         end
         S2: begin
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A > B)? 1'b1 : 1'b0;
         end
         S3: begin
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A > B)? 1'b1 : 1'b0;
         end
         default: begin
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A > B)? 1'b1 : 1'b0;
         end
      endcase
   end

endmodule

module gcd_controlpath (
   input clk,                   // Clock signal
   input rst,                   // Active High Synchronous reset signal
   input go,                   // Start GCD calculation signal
   input equal,                // A_ff equals B_ff
   input greater_than,         // A_ff is greater than B_ff
   output [1:0] controlpath_state, // Current state to datapath
   output done                 // Indicates completion of GCD calculation
);

   // Internal state registers
   logic [1:0] curr_state,      // Current state of FSM
   logic [1:0] next_state;      // Next state of FSM

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff

   // State latching logic: Update current state on clock edge
   always_ff @(posedge clk) begin
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
            next_state = curr_state;
         end
         S1: begin
            next_state = S0;
         end
         S2: begin
            next_state = S1;
         end
         S3: begin
            next_state = S2;
         end
         default: begin
            next_state = S0;
         end
      endcase
   end

   // Output logic: Generate 'done' signal when computation is complete
   always_ff @(posedge clk) begin
     if(rst) begin
        done <= 1'b0;             // On reset, 'done' is low
     end else begin
        done <= (curr_state == S1); // 'done' is asserted when in state S1
     end
   end

   // Assign current state to output for datapath
   assign controlpath_state = curr_state;

endmodule