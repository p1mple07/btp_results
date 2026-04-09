module gcd_top #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
) (
   input                     clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input  [WIDTH-1:0]        A,                  // Input operand A
   input  [WIDTH-1:0]        B,                  // Input operand B
   input                     go,                // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done               // Signal to indicate completion of computation
);

   // Internal signals to communicate between control path and data path
   logic equal;                     // Signal indicating A == B
   logic greater_than;              // Signal indicating A > B
   logic [1:0] controlpath_state;   // Current state of the control FSM

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
   #( .WIDTH(WIDTH) )
   gcd_datapath_inst (
      .clk               (clk),               // Connect clock signal
      .rst               (rst),               // Connect reset signal
      .A                 (A),                 // Connect input A
      .B                 (B),                 // Connect input B
      .controlpath_state (controlpath_state), // Connect current state from control path
      .done              (done),              // Output done signal
      .shift_count        (shift_count),       // Track factors of 2 removed
      .A_ff              (A_ff),             // Register to hold intermediate value of A
      .B_ff              (B_ff),             // Register to hold intermediate value of B
      .OUT               (OUT)                // Output GCD result
   );
endmodule


// Datapath module for Stein's algorithm implementation
module gcd_datapath  #(
   parameter WIDTH = 4                           // Bit-width of operands
) (
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
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization
   localparam S1 = 2'd1;    // State 1: A and B are both even
   localparam S2 = 2'd2;    // State 2: A is even, B is odd
   localparam S3 = 2'd3;    // State 3: A is odd, B is even
   localparam S4 = 2'd4;    // State 4: A and B are both odd

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         A_ff <= 'b0;
         B_ff <= 'b0;
      end else begin
         case (controlpath_state)
            S0: begin
               A_ff <= A;
               B_ff <= B;
            end
            S1: begin
               if (A == B) begin
                  equal = 1'b1;
                  greater_than = 0;
               else begin
                  equal = 0;
                  greater_than = 1;
               end
            end
            S2: begin
               if (A > B) begin
                  greater_than = 1;
               else begin
                  greater_than = 0;
               end
            end
            S3: begin
               if (B > A) begin
                  greater_than = 1;
               else begin
                  greater_than = 0;
               end
            end
            S4: begin
               if (A == B) begin
                  equal = 1'b1;
               else begin
                  equal = 0;
               end
            end
            default: begin
               A_ff <= 'b0;
               B_ff <= 'b0;
            end
         endcase
      end
   end

   // State transition logic
   always_comb begin
      case(controlpath_state)
         S0: begin
            if (!go) begin
               controlpath_state = S0;
            end else begin
               if (equal) begin
                  controlpath_state = S1;
               elsif (greater_than) begin
                  controlpath_state = S2;
               elsif (A == 0) begin
                  controlpath_state = S3;
               endcase
         endcase
   end

   // Register to track factors of 2 removed
   logic [1:0] shift_count = 0;

   // Output logic: Generate 'done' signal when computation is complete
   always_ff @ (posedge clk) begin
      if (rst) begin
         done <= 0;
      end else begin
         done <= (A == B);
      end
   end

   // Assign current state to output for datapath
   assign controlpath_state = (A == B) ? S1 : S0;

endmodule

// Control path module for Stein's algorithm implementation
module gcd_controlpath (
   input                    clk,               // Clock signal
   input                    rst,               // Active High Synchronous reset
   input                    go,                // Start signal to begin GCD computation
   input                    equal,             // From Datapath: A_ff equals B_ff
   input                    greater_than,      // From Datapath: A_ff > B_ff
   output logic [1:0]       controlpath_state,  // Current state to Datapath
   output logic             done               // Indicates completion of GCD calculation
);

   // Internal state register
   reg [1:0] curr_state = S0;

   // State transitions based on control inputs
   always_comb begin
      case(curr_state)
         S0: begin
            if (!go) begin
               curr_state = S0;
            end else begin
               if (equal) begin
                  curr_state = S1;
               elsif (greater_than) begin
                  curr_state = S2;
               else begin
                  curr_state = S3;
               end
            end
         end
         S1: begin
            curr_state = S0;
         end
         S2: begin
            if (A == B) begin
               curr_state = S1;
            else if (A > B) begin
               curr_state = S2;
            else begin
               curr_state = S3;
            end
         end
         S3: begin
            if (A == B) begin
               curr_state = S1;
            else if (A > B) begin
               curr_state = S2;
            else begin
               curr_state = S3;
            end
         end
         default: begin
            curr_state = S0;
         end
      endcase
   end

   // Output logic: Generate 'done' signal when computation is complete
   always_ff @ (posedge clk) begin
      if (rst) begin
         done <= 0;
      end else begin
         done <= (curr_state == S1);
      end
   end

   // Assign current state to output for Datapath
   assign controlpath_state = curr_state;

endmodule