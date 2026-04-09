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
   logic [1:0] controlpath_state;   // Current state of the control FSM

   // Instantiate the control path module
   gcd_controlpath gcd_controlpath_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
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
      .OUT               (OUT)                // Output GCD result
   );

   // Register to track factors of 2 removed
   logic [WIDTH-1:0] twos_factor_count;

endmodule

// Data path module for GCD computation using Stein's algorithm
module gcd_datapath  #(
   parameter WIDTH = 4                           // Bit-width of operands
   )(
   input                     clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input  [WIDTH-1:0]        A,                  // Input operand A
   input  [WIDTH-1:0]        B,                  // Input operand B
   input  [WIDTH-1:0]        twos_factor_count,  // Count of factors of 2 removed
   output logic              equal,              // Signal indicating A == B
   output logic              twos_factor_count,   // Count of factors of 2 removed
   output logic  [WIDTH-1:0] OUT                 // Output GCD result
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers to zero
         A_ff <= 'b0;
         B_ff <= 'b0;
         equal <= 'b0;
         twos_factor_count <= 0;
         OUT  <= 'b0;
      end else begin
         case (controlpath_state)
            S0: begin
                // In state S0, load input values into registers
                A_ff <= A;
                B_ff <= B;
             end
            S1: begin
                // In state S1, check if A and B are equal
                equal <= (A == B);
                // If equal, output the result and set next state to S0
                OUT  <= A;
                next_state = S0;
             end
            S2: begin
                // In state S2, check if A or B is even
                if (A & B'm1 == 0) begin
                   // Both A and B are even, divide by 2 and increment factor count
                   A_ff <= A >> 1;
                   B_ff <= B >> 1;
                   twos_factor_count <= twos_factor_count + 1;
                   equal <= (A == B);
                   next_state = S1;
                end else if (A & B'm1 == 0) begin
                   // Only A is even, divide by 2 and increment factor count
                   A_ff <= A >> 1;
                   equal <= (A == B);
                   next_state = S2;
                end
                // If B is even, stay in S2
                else begin
                   B_ff <= B >> 1;
                   equal <= (A == B);
                   next_state = S2;
                end
             end
            S3: begin
                // In state S3, check if A is odd and B is even
                if (A'm1 & B'm1 == 0) begin
                   // Only B is even, divide by 2 and increment factor count
                   B_ff <= B >> 1;
                   equal <= (A == B);
                   next_state = S3;
                end
                // If both are odd, subtract B from A and increment factor count
                else begin
                   A_ff <= A - B;
                   twos_factor_count <= twos_factor_count + 1;
                   equal <= (A == B);
                   next_state = S2;
                end
             end
            default: begin
                A_ff <= 'b0;
                B_ff <= 'b0;
                equal <= 'b0;
                twos_factor_count <= 0;
                OUT  <= 'b0;
            endcase
         end
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
            // In state S1, check if A and B are equal
            equal        = (A == B);
          end
          S2: begin
            // In state S2, check if A or B is even
            if (A & B'm1 == 0) begin
              // Both A and B are even, divide by 2 and increment factor count
              A_ff <= A >> 1;
              B_ff <= B >> 1;
              twos_factor_count <= twos_factor_count + 1;
              equal        = (A == B);
            end
            else if (A & B'm1 == 0) begin
              // Only A is even, divide by 2 and increment factor count
              A_ff <= A >> 1;
              equal        = (A == B);
            end
            else begin
              // B is even, divide by 2 and increment factor count
              B_ff <= B >> 1;
              twos_factor_count <= twos_factor_count + 1;
              equal        = (A == B);
            end
          end
          S3: begin
            // In state S3, check if A is odd and B is even
            if (A'm1 & B'm1 == 0) begin
              // Only B is even, divide by 2 and increment factor count
              B_ff <= B >> 1;
              equal        = (A == B);
            end
            else begin
              // Both are odd, subtract B from A
              A_ff <= A - B;
              equal        = (A == B);
              twos_factor_count <= twos_factor_count + 1;
            end
          end
          default: begin
            equal        = 'b0;
            twos_factor_count <= 0;
          end
      endcase
   end

   // Assign current state to output for datapath
   assign controlpath_state = curr_state;

endmodule

// Control path module for GCD computation FSM using Stein's algorithm
module gcd_controlpath (
   input                    clk,               // Clock signal
   input                    rst,               // Active High Synchronous reset
   input                    go,                // Start GCD calculation signal
   input                    equal,             // From datapath: A == B
   input                    twos_factor_count,  // Count of factors of 2 removed
   output logic [1:0]       controlpath_state, // Current state to Datapath
   output logic             done               // Indicates completion of GCD calculation
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [1:0] next_state;  // Next state of FSM

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A or B is even
   localparam S3 = 2'd3;    // State 3: Both A and B are odd

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
                next_state = S1;         // If A == B, transition to S1
             else
                next_state = S3;         // If B > A, transition to S3
         end
         S1: begin
             // State S1: Check if A and B are equal
             if(equal)
                next_state = S0;           // Return to S0 after equality is found
             else
                next_state = S2;         // If A > B, transition to S2
         end
         S2: begin
             // State S2: Check if A or B is even
             if(equal)
                next_state = S1;         // If A == B after division, transition to S1
             else
                next_state = S3;         // If B > A after division, transition to S3
         end
         S3: begin
             // State S3: Both A and B are odd
             if(equal)
                next_state = S1;         // If A == B after subtraction, transition to S1
             else
                next_state = S2;         // If B > A after subtraction, transition to S2
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

endmodule
