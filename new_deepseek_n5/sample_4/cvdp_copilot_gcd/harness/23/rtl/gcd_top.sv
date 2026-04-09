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
   logic [1:0] shift_count;         // Number of shifts performed

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
      .shift_count        (shift_count),       // Track number of shifts
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

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization state
   localparam S1 = 2'd1;    // State 1: Processing state
   localparam S2 = 2'd2;    // State 2: Shift count complete

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         // On reset, initialize registers
         A_reg <= 'b0;
         B_reg <= 'b0;
         OUT  <= 'b0;
      end else begin
         case (controlpath_state)
            S0: begin
               // In state S0, load input values into registers
               A_reg <= A;
               B_reg <= B;
            end
            S1: begin
               // In state S1, perform Stein's algorithm steps
               if (A == B) begin
                  // If A == B, output the result
                  OUT  <= A_reg;
               end else if (A > B) begin
                  // If A > B, subtract B from A
                  A_reg <= A_reg - B_reg;
               end else begin
                  // If B > A, subtract A from B
                  B_reg <= B_reg - A_reg;
               end
            end
            S2: begin
               // In state S2, shift right if both even
               if (A_reg & 1 == 0 && B_reg & 1 == 0) begin
                  A_reg <= A_reg >> 1;
                  B_reg <= B_reg >> 1;
                  shift_count <= shift_count + 1;
               end else if (A_reg & 1 == 0) begin
                  A_reg <= A_reg >> 1;
               end else if (B_reg & 1 == 0) begin
                  B_reg <= B_reg >> 1;
               end
            end
            default: begin
               A_reg <= 'b0;
               B_reg <= 'b0;
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
            equal        = (A == B);
            greater_than = (A >  B);
          end
         S1: begin
            // In state S1, compare current values in registers A_reg and B_reg
            equal        = (A_reg == B_reg);
            greater_than = (A_reg >  B_reg);
          end
         S2: begin
            // In state S2, compare current values in registers A_reg and B_reg
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
   input                    equal,             // From Datapath: A_reg equals B_reg
   input                    greater_than,      // From Datapath: A_reg > B_reg
   output logic [1:0]       controlpath_state,  // Current state to Datapath
   output logic             done               // Indicates completion of GCD calculation
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [1:0] next_state;  // Next state of FSM

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Processing state
   localparam S2 = 2'd2;    // State 2: Shift count complete

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
                next_state = S2;         // If B > A, go to state S3
         end
         S1: begin
             // State S1: Processing state
             next_state = S1;           // Stay in S1 after processing
         end
         S2: begin
             // State S2: A_reg > B_reg
             if(equal)
                next_state = S1;         // If A_reg == B_reg after shift, go to S1
             else if (greater_than)
                next_state = S2;         // If A_reg > B_reg, stay in S2
             else
                next_state = S3;         // If B_reg > A_reg, go to S3
         end
         S3: begin
             // State S3: B_reg > A_reg
             if (equal)
                next_state = S1;         // If A_reg == B_reg after shift, go to S1
             else if (greater_than)
                next_state = S3;         // If B_reg > A_reg, stay in S3
             else
                next_state = S2;         // If A_reg > B_reg, go to S2
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