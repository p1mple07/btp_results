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
   logic [1:0] num_factors_2; // Register to track number of factors of 2 removed

   // Instantiate the control path module
   gcd_controlpath gcd_controlpath_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .go                (go),                // Connect go signal
      .num_factors_2    (num_factors_2),    // Connect num_factors_2
      .OUT               (OUT),               // Connect output GCD result
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
      .num_factors_2    (num_factors_2),    // Connect num_factors_2
      .OUT               (OUT)                // Output GCD result
   );

endmodule

// Control path module for GCD computation FSM
module gcd_controlpath (
   input                    clk,               // Clock signal
   input                    rst,               // Active High Synchronous reset
   input                    go,                // Start GCD calculation signal
   input                    num_factors_2,      // Number of factors of 2 removed
   output logic [1:0]       controlpath_state, // Current state to Datapath
   output logic             done               // Indicates completion of GCD calculation
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [1:0] next_state;  // Next state of FSM

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: Both A and B are even
   localparam S3 = 2'd3;    // State 3: Both A and B are odd

   // State latching logic: Update current state on clock edge
   always_ff @ (posedge clk) begin
      if (rst) begin
         curr_state   <= S0;   // On reset, set state to S0
         num_factors_2 <= 2'd0; // Reset number of factors of 2 removed
      end else begin
         curr_state   <= next_state;   // Transition to next state
         num_factors_2 <= next_num_factors_2; // Update number of factors of 2 removed
      end
   end

   // State transition logic: Determine next state based on current state and inputs
   always_comb begin
      case(curr_state)
         S0: begin
             // State S0: Waiting for 'go' signal
             if(!go)
                next_state = S0;         // Remain in S0 until 'go' is asserted
             else if (A & B == 0)
                next_state = A ? B : A; // If one of A or B is 0, make both A and B the same
             else if (A & B == A)
                next_state = S1;         // If A == B, both are even
             else if (A & B == A & 1)
                next_state = S2;         // If both are odd, go to S2
             else
                next_state = S3;         // If B > A, go to S3
         end
         S1: begin
             // State S1: Both A and B are even
             // Remove a factor of 2
             if (A == 2'b00) begin
                next_state = S2;
                num_factors_2 <= num_factors_2 + 1;
             end else begin
                next_state = S1;
             end
         end
         S2: begin
             // State S2: Both A and B are odd
             // Remove a factor of 2
             if (A == 2'b10) begin
                next_state = S3;
                num_factors_2 <= num_factors_2 + 1;
             end else begin
                next_state = S2;
             end
         end
         S3: begin
             // State S3: One of A or B is 0
             // Set the non-zero value to both A and B
             if (A == 2'b00) begin
                A <= B;
                num_factors_2 <= 2'd0;
             end else if (B == 2'b00) begin
                B <= A;
                num_factors_2 <= 2'd0;
             end else begin
                next_state = S3;
             end
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

// Datapath module for GCD computation
module gcd_datapath  #(
   parameter WIDTH = 4                           // Bit-width of operands
) (
   input                     clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input  [WIDTH-1:0]        A,                  // Input operand A
   input  [WIDTH-1:0]        B,                  // Input operand B
   input  [1:0]              num_factors_2,      // Number of factors of 2 removed
   output logic              equal,              // Signal indicating A_ff == B_ff
   output logic              num_factors_2,        // Output number of factors of 2 removed
   output logic  [WIDTH-1:0] OUT                 // Output GCD result
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization
   localparam S1 = 2'd1;    // State 1: Both A and B are even
   localparam S2 = 2'd2;    // State 2: Both A and B are odd
   localparam S3 = 2'd3;    // State 3: One of A or B is 0

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
                // In state S1, both A and B are even
                // Perform arithmetic shift by 1 (divide by 2)
                if (num_factors_2 > 0) begin
                   A_ff <= A >> 1;
                   B_ff <= B >> 1;
                   num_factors_2 <= num_factors_2 - 1;
                end else {
                   A_ff <= A;
                   B_ff <= B;
                }
             end
            S2: begin
                // In state S2, both A and B are odd
                // Perform arithmetic shift by 1 (divide by 2)
                if (num_factors_2 > 0) begin
                   A_ff <= A >> 1;
                   B_ff <= B >> 1;
                   num_factors_2 <= num_factors_2 - 1;
                end else {
                   A_ff <= A;
                   B_ff <= B;
                }
             end
            S3: begin
                // In state S3, one of A or B is 0
                // Set the non-zero value to both A and B
                if (A == 2'b00) begin
                   A_ff <= B;
                   num_factors_2 <= 2'd0;
                end else if (B == 2'b00) begin
                   B_ff <= A;
                   num_factors_2 <= 2'd0;
                end else {
                   A_ff <= A;
                   B_ff <= B;
                }
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
            // In state S0, compare initial input values A and B
            equal        = (A == B)? 1'b1 : 1'b0;
          end
          S1: begin
            // In state S1, both A and B are even
            equal        = (A == B)? 1'b1 : 1'b0;
          end
          S2: begin
            // In state S2, both A and B are odd
            equal        = (A == B)? 1'b1 : 1'b0;
          end
          S3: begin
            // In state S3, one of A or B is 0
            equal        = (A == B)? 1'b1 : 1'b0;
          end
          default: begin
            // In other states, compare the current values in registers A_ff and B_ff
            equal        = (A == B)? 1'b1 : 1'b0;
          end
      endcase
   end

endmodule
