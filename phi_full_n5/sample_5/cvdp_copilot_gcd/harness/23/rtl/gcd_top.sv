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

   // Internal signals to communicate between control path and data path
   logic equal;                     // Signal indicating A == B
   logic [WIDTH-1:0] controlpath_state;   // Current state of the control FSM

   // Instantiate the control path module
   gcd_controlpath gcd_controlpath_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .equal             (equal),             // Connect equal signal from datapath
      .controlpath_state (controlpath_state), // Output current state to datapath
      .done              (done)               // Output done signal
   );

   // Instantiate the datapath module
   gcd_datapath
   #( .WIDTH(WIDTH)
   ) gcd_datapath_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .factor_count     (factor_count), // Connect factor count to datapath
      .equal             (equal),             // Output equal signal to control path
      .controlpath_state (controlpath_state), // Connect current state from control path
      .OUT               (OUT)                // Output GCD result
   );

endmodule

// Control path module for GCD computation FSM
module gcd_controlpath (
   input                    clk,               // Clock signal
   input                    rst,               // Active High Synchronous reset
   input                    equal,             // From datapath: A_ff equals B_ff
   output logic [1:0]       controlpath_state, // Current state to datapath
   output logic             done               // Indicates completion of GCD calculation
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [1:0] next_state;  // Next state of FSM

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Check if A or B is even
   localparam S2 = 2'd2;    // State 2: Remove a factor of 2 from both A and B
   localparam S3 = 2'd3;    // State 3: Compute GCD of A and B

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
             else if (A[WIDTH-1] == 'b0)
                next_state = S1;         // If A is even, go to S1
             else
                next_state = S3;         // If A is odd, go to S3
         end
         S1: begin
             // State S1: A is even, go to S2
             next_state = S2;
         end
         S2: begin
             // State S2: Remove a factor of 2 from both A and B
             if (A[WIDTH-1] == 'b0)
                next_state = S2;         // Both A and B are even, stay in S2
             else if (A[WIDTH-1] & B[WIDTH-1] == 'b0)
                next_state = S3;         // Both A and B are odd, go to S3
             else
                next_state = S1;         // Only one is even, go to S1
         end
         S3: begin
             // State S3: Compute GCD of A and B
             next_state = S3;
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
        done <= (curr_state == S3); // 'done' is asserted when in state S3
     end
   end

   // Assign current state to output for datapath
   assign controlpath_state = curr_state;

endmodule

// Datapath module for GCD computation using Stein's algorithm
module gcd_datapath  #(
   parameter WIDTH = 4                           // Bit-width of operands
) (
   input                     clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input  [WIDTH-1:0]        A,                  // Input operand A
   input  [WIDTH-1:0]        B,                  // Input operand B
   input  [1:0]              controlpath_state,  // Current state from control path
   output logic  [WIDTH-1:0] OUT,                 // Output GCD result
   output logic              factor_count       // Register to track factored-out twos
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // State encoding for control signals

   // Register to keep track of the number of times a factor of 2 is removed
   logic [3:0] factor_count;

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         A_ff <= 'b0;
         B_ff <= 'b0;
         OUT  <= 'b0;
         factor_count <= 4'd0; // Initialize factor count
      end else begin
         case (controlpath_state)
            S0: begin
                // In state S0, load input values into registers
                A_ff <= A;
                B_ff <= B;
             end
            S1: begin
                // In state S1, check if A or B is even
                if (A[WIDTH-1] == 'b0)
                   A_ff <= A_ff >> 1;
                   B_ff <= B_ff >> 1;
                   factor_count <= factor_count + 1;
             end
            S2: begin
                // In state S2, remove a factor of 2 from both A and B if possible
                if (A[WIDTH-1] == 'b0)
                   A_ff <= A_ff >> 1;
                   B_ff <= B_ff >> 1;
                   factor_count <= factor_count + 1;
             end
            S3: begin
                // In state S3, compute GCD of A_ff and B_ff
                // Use existing logic to compare and subtract until A_ff == B_ff
                // (Implement the comparison and subtraction logic here)
                // For example:
                // if (A_ff > B_ff) A_ff <= A_ff - B_ff;
                // else if (B_ff > A_ff) B_ff <= B_ff - A_ff;
                // Add your GCD computation logic here
             end
            default: begin
                A_ff <= A;
                B_ff <= B;
                OUT  <= 'b0;
                factor_count <= factor_count; // Keep factor count unchanged
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
          end
          S1: begin
            // In state S1, both A and B are even
            equal        = (A == B)? 1'b1 : 1'b0;
          end
          S2: begin
            // In state S2, both A and B are even
            equal        = (A == B)? 1'b1 : 1'b0;
          end
          S3: begin
            // In state S3, A_ff == B_ff
            equal        = 1'b1;
          end
      endcase
   end
endmodule
