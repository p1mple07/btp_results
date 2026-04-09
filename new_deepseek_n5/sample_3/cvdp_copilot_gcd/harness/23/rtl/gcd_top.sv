module gcd_top #(
   parameter WIDTH = 4
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
   logic [1:0] controlpath_state;   // Current state of the control FSM

   // Instantiate the control path module
   gcd_controlpath gcd_controlpath_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .go                (go),                // Connect go signal
      .equal             (equal),             // Connect equal signal from datapath
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
endmodule


// Datapath module for GCD computation using Stein's algorithm
module gcd_datapath  #(
   parameter WIDTH = 4                           // Bit-width of operands
   )(
   input                     clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input  [WIDTH-1:0]        A,                  // Input operand A
   input  [WIDTH-1:0]        B,                  // Input operand B
   input  [1:0]              controlpath_state,  // Current state from control path
   output logic              equal,              // Signal indicating A_ff == B_ff
   output logic              done               // Signal indicating computation completion
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;
   logic [2:0] shift_count; // Track number of shifts

   // State encoding for control signals
   localparam S0 = 2'd0;    // Initialization state
   localparam S1 = 2'd1;    // State after removing factors of 2
   localparam S2 = 2'd2;    // State after handling even/odd cases
   localparam S3 = 2'd3;    // State after handling subtraction

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         A_ff <= 'b0;
         B_ff <= 'b0;
         equal <= 'b0;
         shift_count <= 0;
      end else begin
         case (controlpath_state)
            S0: begin
               // Load input values into registers
               A_ff <= A;
               B_ff <= B;
            end
            S1: begin
               // Remove factors of 2
               if (A & 1) != (B & 1) begin
                  // One even, one odd
                  if (A & 1) == 0 begin
                     B_ff <= B >> 1;
                     shift_count <= shift_count + 1;
                  end else begin
                     A_ff <= A >> 1;
                     shift_count <= shift_count + 1;
                  end
               end else begin
                  // Both even
                  A_ff <= A >> 1;
                  B_ff <= B >> 1;
                  shift_count <= shift_count + 1;
               end
            end
            S2: begin
               // Handle even/odd cases
               if (A & 1) == 0 begin
                  A_ff <= A_ff >> 1;
               end else if (B & 1) == 0 begin
                  B_ff <= B_ff >> 1;
               end else begin
                  // Both odd: subtract and continue
                  A_ff <= A_ff - B_ff;
                  B_ff <= B_ff - A_ff;
               end
            end
            S3: begin
               // Continue handling cases
               if (A & 1) == 0 begin
                  B_ff <= B_ff >> 1;
               end else if (B & 1) == 0 begin
                  A_ff <= A_ff >> 1;
               end else begin
                  // Both odd: continue subtraction
                  A_ff <= A_ff - B_ff;
                  B_ff <= B_ff - A_ff;
               end
            end
            default: begin
               A_ff <= 'b0;
               B_ff <= 'b0;
               equal <= 'b0;
               shift_count <= 0;
            end
         endcase
      end
   end

   // Generating control response signals for the control path FSM
   always_comb begin
      case(controlpath_state)
         S0: begin
            equal        = (A == B);
            done        = 0;
         end
         S1: begin
            done        = 0;
         end
         S2: begin
            done        = 0;
         end
         S3: begin
            done        = 0;
         end
         default: begin
            done        = 0;
         end
      endcase
   end
endmodule

// Control path module for GCD computation FSM
module gcd_controlpath (
   input                    clk,               // Clock signal
   input                    rst,               // Active High Synchronous reset
   input                    go,                // Start GCD calculation signal
   input                    equal,             // From Datapath: A_ff equals B_ff
   output logic [1:0]       controlpath_state,  // Current state to Datapath
   output logic             done               // Indicates completion of GCD calculation
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [2:0] next_state;  // Next state of FSM

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
            // Waiting for 'go' signal
            if(!go)
               next_state = S0;         // Remain in S0 until 'go' is asserted
            else if (equal)
               next_state = S1;         // If A == B, computation is complete
            else
               next_state = S2;         // If A != B, proceed to S2
         end
         S1: begin
            // Computation complete
            next_state = S0;           // Return to S0 after completion
         end
         S2: begin
            // A is even
            if (A & 1) == 0 begin
               next_state = S1;         // If A is even, go to S1
            end else begin
               next_state = S3;         // If A is odd, go to S3
            end
         end
         S3: begin
            // B is even
            if (B & 1) == 0 begin
               next_state = S2;         // If B is even, stay in S2
            end else begin
               next_state = S1;         // If B is odd, go to S1
            end
         end
         default: next_state = S0;
      endcase
   end

   // Output logic: Generate 'done' signal when computation is complete
   always_ff @ (posedge clk) begin
     if(rst) begin
        done <= 1'b0;             // On reset, 'done' is low
     end else begin
        done <= 1'b1;             // 'done' is asserted when in state S1
     end
   end

   // Assign current state to output for datapath
   assign controlpath_state = curr_state;

endmodule