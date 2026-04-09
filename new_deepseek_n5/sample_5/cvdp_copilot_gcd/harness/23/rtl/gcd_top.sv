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
   logic [1:0] shift_count;         // Count of shifts performed

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
      .shift_count        (shift_count),       // Track factors of 2 removed
      .equal             (equal),             // Output equal signal to control path
      .greater_than      (greater_than),      // Output greater_than signal to control path
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
   input  logic              shift_count,         // Track factors of 2 removed
   output logic              equal,              // Signal indicating A == B
   output logic              greater_than,       // Signal indicating A > B
   output logic  [WIDTH-1:0] OUT                 // Output GCD result
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_reg;
   logic [WIDTH-1:0] B_reg;

   // State encoding for control path
   localparam S0 = 2'd0;    // State 0: Initialization
   localparam S1 = 2'd1;    // State 1: Shift both
   localparam S2 = 2'd2;    // State 2: Shift A only
   localparam S3 = 2'd3;    // State 3: Shift B only
   localparam S4 = 2'd4;    // State 4: Compute result

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers to zero
         A_reg <= 0;
         B_reg <= 0;
         shift_count <= 0;
         OUT <= 0;
      end else begin
         case (controlpath_state)
            S0: begin
               // Load input values into registers
               A_reg <= A;
               B_reg <= B;
            end
            S1: begin
               // If both even, shift both and increment count
               if (A & 1 == 0 && B & 1 == 0) begin
                  A_reg <= A_reg >> 1;
                  B_reg <= B_reg >> 1;
                  shift_count <= shift_count + 1;
               end
            end
            S2: begin
               // If A even, shift A
               if (A & 1 == 0) begin
                  A_reg <= A_reg >> 1;
               end
            end
            S3: begin
               // If B even, shift B
               if (B & 1 == 0) begin
                  B_reg <= B_reg >> 1;
               end
            end
            default: begin
               A_reg <= 0;
               B_reg <= 0;
               shift_count <= 0;
               OUT <= 0;
            end
         endcase
      end
   end

   // Generating control response signals for the control path FSM
   always_comb begin
      case(controlpath_state)
         S0: begin
            // In state S0: Compare initial input values
            equal        = (A == B);
            greater_than = (A >  B);
          end
         S1: begin
            // In state S1: Both even, shift and increment count
            if (A & 1 == 0 && B & 1 == 0) begin
               equal        = (A_reg == B_reg);
               greater_than = (A_reg >  B_reg);
            end else begin
               equal        = (A_reg == B_reg);
               greater_than = (A_reg >  B_reg);
            end
          end
         S2: begin
            // In state S2: A even, shift A
            if (A & 1 == 0) begin
               equal        = (A_reg == B_reg);
               greater_than = (A_reg >  B_reg);
            end else begin
               equal        = (A_reg == B_reg);
               greater_than = (A_reg >  B_reg);
            end
          end
         S3: begin
            // In state S3: B even, shift B
            if (B & 1 == 0) begin
               equal        = (A_reg == B_reg);
               greater_than = (A_reg >  B_reg);
            end else begin
               equal        = (A_reg == B_reg);
               greater_than = (A_reg >  B_reg);
            end
          end
         default: begin
            // In other states, compare the current values in registers
            equal        = (A_reg == B_reg);
            greater_than = (A_reg >  B_reg);
          end
      endcase
   end
endmodule

// Control path module for Stein's GCD computation FSM
module gcd_controlpath (
   input                    clk,               // Clock signal
   input                    rst,               // Active High Synchronous reset
   input                    go,                // Start GCD calculation signal
   input                    equal,             // From Datapath: A == B
   input                    greater_than,      // From Datapath: A > B
   output logic [1:0]       controlpath_state,  // Current state to Datapath
   output logic             done               // Indicates completion of GCD calculation
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [1:0] next_state;  // Next state of FSM

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Shift both
   localparam S2 = 2'd2;    // State 2: Shift A only
   localparam S3 = 2'd3;    // State 3: Shift B only
   localparam S4 = 2'd4;    // State 4: Compute result

   // State latching logic: Update current state on clock edge
   always_ff @ (posedge clk) begin
      if (rst) begin
         curr_state <= S0;   // On reset, set state to S0
      end else begin
         curr_state <= next_state;   // Transition to next state
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
             // State S1: Both even, shift both and increment count
             if (equal) begin
                next_state = S1;         // If A == B after shift, stay in S1
             else if (greater_than)
                next_state = S2;         // If A > B, go to state S2
             else
                next_state = S3;         // If B > A, go to state S3
         end
         S2: begin
             // State S2: A even, shift A
             if (equal) begin
                next_state = S1;         // If A == B after shift, go to S1
             else if (greater_than)
                next_state = S2;         // If A > B, stay in S2
             else
                next_state = S3;         // If B > A, go to state S3
         end
         S3: begin
             // State S3: B even, shift B
             if (equal) begin
                next_state = S1;         // If A == B after shift, go to S1
             else if (greater_than)
                next_state = S2;         // If A > B, go to state S2
             else
                next_state = S3;         // If B > A, stay in S3
         end
         default: begin
             next_state = S0;         // Default state
         end
      endcase
   end

   // Output logic: Generate 'done' signal when computation is complete
   always_ff @ (posedge clk) begin
     if(rst) begin
        done <= 1'b0;             // On reset, 'done' is low
     end else begin
        done <= (curr_state == S4); // 'done' is asserted when in state S4
     end
   end

   // Assign current state to output for datapath
   assign controlpath_state = curr_state;

   // Compute final result
   always_comb begin
      case(curr_state)
         S4: begin
             // If both A and B are equal, output the value multiplied by 2^shift_count
             OUT <= A_reg << shift_count;
         default: begin
             OUT <= 0;
         end
      end
   end
endmodule