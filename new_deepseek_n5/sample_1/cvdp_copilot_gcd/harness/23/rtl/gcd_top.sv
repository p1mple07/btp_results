module gcd_top #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
   )(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Internal signals to communicate between control path and data path
   logic equal;                     // Signal indicating A == B
   logic greater_than;              // Signal indicating A > B
   logic [1:0] controlpath_state;   // Current state of the control FSM
   logic shift_count;               // Track number of shifts by 2

   // Instantiate the control path module
   gcd_controlpath gcd_controlpath_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .go                (go),                // Connect go signal
      .equal             (equal),             // Connect equal signal from datapath
      .greater_than      (greater_than),      // Connect greater_than signal from datapath
      .controlpath_state (controlpath_state), // Output current state to datapath
      .done              (done)               // Output done signal
   );

   // Instantiate the data path module
   gcd_datapath
   #( .WIDTH(WIDTH)
   ) gcd_datapath_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .controlpath_state (controlpath_state), // Connect current state from control path
      .equal             (equal),             // Output equal signal to control path
      .greater_than      (greater_than),      // Output greater_than signal to control path
      .shift_count       (shift_count),       // Track number of shifts by 2
      .OUT               (OUT)                // Output GCD result
   );
endmodule


// Datapath module for Stein's GCD computation
module gcd_datapath  #(
   parameter WIDTH = 4                           // Bit-width of operands
   )(
   input                     clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input  [WIDTH-1:0]        A,                  // Input operand A
   input  [WIDTH-1:0]        B,                  // Input operand B
   input  [1:0]              controlpath_state,  // Current state from control path
   output logic              equal,              // Signal indicating A == B
   output logic              greater_than,       // Signal indicating A > B
   output logic  [WIDTH-1:0] OUT                 // Output GCD result
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_reg;
   logic [WIDTH-1:0] B_reg;
   logic [WIDTH-1:0] shift_reg;

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization state
   localparam S1 = 2'd1;    // State 1: Processing state
   localparam S2 = 2'd2;    // State 2: A and B both even
   localparam S3 = 2'd3;    // State 3: A even, B odd
   localparam S4 = 2'd4;    // State 4: A odd, B even
   localparam S5 = 2'd5;    // State 5: A and B odd

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers to zero
         A_reg <= 'b0;
         B_reg <= 'b0;
         shift_reg <= 0;
      end else begin
         case (controlpath_state)
            S0: begin
                // In state S0, load input values into registers
                A_reg <= A;
                B_reg <= B;
                shift_reg <= 0;
             end
            S1: begin
                // In state S1, check if A and B are equal
                if (A_reg == B_reg)
                   OUT  <= A_reg;
                else
                   case (A_reg & 1, B_reg & 1)
                      1'd1, 1'd1: // Both odd
                          // Transition to state S5
                          controlpath_state = S5;
                      1'd1, 1'd0: // A odd, B even
                          // Transition to state S3
                          controlpath_state = S3;
                      1'd0, 1'd1: // A even, B odd
                          // Transition to state S4
                          controlpath_state = S4;
                      1'd0, 1'd0: // Both even
                          // Transition to state S2 and shift
                          controlpath_state = S2;
                          shift_reg <= shift_reg + 1;
                  endcase
             end
         endcase
      end
   end

   // Generating control response signals for the control path FSM
   always_comb begin
      case(controlpath_state)
         S0: begin
            equal        = (A == B);
            greater_than = (A >  B);
          end
         S1: begin
            equal        = (A_reg == B_reg);
            greater_than = (A_reg >  B_reg);
          end
         S2: begin
            // Both even, shift right
            A_reg <= A_reg >> 1;
            B_reg <= B_reg >> 1;
            shift_reg <= shift_reg + 1;
          end
         S3: begin
            // A even, B odd, shift A
            A_reg <= A_reg >> 1;
          end
         S4: begin
            // A odd, B even, shift B
            B_reg <= B_reg >> 1;
          end
         S5: begin
            // Both odd, subtract 1 from A
            A_reg <= A_reg - 1;
          end
         default: begin
            A_reg <= 'b0;
            B_reg <= 'b0;
            shift_reg <= 0;
         end
      endcase
   end

   // Output logic: Generate 'done' signal when computation is complete
   always_ff @ (posedge clk) begin
     if(rst) begin
        done <= 1'b0;             // On reset, 'done' is low
     end else begin
        done <= 1 == controlpath_state; // 'done' is asserted when in state S1
     end
   end

   // Assign current state to output for datapath
   assign controlpath_state = shift_reg;

endmodule

// Control path module for Stein's GCD algorithm FSM
module gcd_controlpath (
   input                    clk,               // Clock signal
   input                    rst,               // Active High Synchronous reset
   input                    go,                // Start GCD calculation signal
   input                    equal,             // From Datapath: A_ff equals B_ff
   input                    greater_than,      // From Datapath: A_ff is greater than B_ff
   output logic [1:0]       controlpath_state,  // Current state to Datapath
   output logic             done               // Indicates completion of GCD calculation
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [1:0] next_state;  // Next state of FSM

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Processing state
   localparam S2 = 2'd2;    // State 2: A and B both even
   localparam S3 = 2'd3;    // State 3: A even, B odd
   localparam S4 = 2'd4;    // State 4: A odd, B even
   localparam S5 = 2'd5;    // State 5: A and B odd

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
                next_state = S3;         // If A > B, go to state S3
             else
                next_state = S4;         // If B > A, go to state S4
         end
         S1: begin
             // State S1: Processing state
             next_state = S1;           // Transition to S1 after processing
         end
         S2: begin
             // State S2: A and B both even
             if(equal)
                next_state = S1;         // If A == B after division, go to S1
             else if (greater_than)
                next_state = S2;         // If A > B, stay in S2
             else
                next_state = S3;         // If B > A, go to S3
         end
         S3: begin
             // State S3: A even, B odd
             if (equal)
                next_state = S1;         // If A == B after division, go to S1
             else if (greater_than)
                next_state = S2;         // If A > B, go to S2
             else
                next_state = S4;         // If B > A, go to S4
         end
         S4: begin
             // State S4: A odd, B even
             if (equal)
                next_state = S1;         // If A == B after division, go to S1
             else if (greater_than)
                next_state = S3;         // If A > B, go to S3
             else
                next_state = S4;         // If B > A, stay in S4
         end
         S5: begin
             // State S5: Both A and B are odd
             if (equal)
                next_state = S1;         // If A == B after subtraction, go to S1
             else if (greater_than)
                next_state = S3;         // If A > B, go to S3
             else
                next_state = S4;         // If B > A, go to S4
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
        done <= 1 == curr_state; // 'done' is asserted when in state S1
     end
   end

   // Assign current state to output for datapath
   assign controlpath_state = curr_state;

endmodule