module gcd_3_ip #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
   )(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // First operand
   input  [WIDTH-1:0]        B,     // Second operand
   input  [WIDTH-1:0]        C,     // Third operand
   input                     go,    // Start GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output GCD result
   output logic              done   // Completion signal
);

   // Internal signals
   logic equal_ab;
   logic equal_bc;
   logic greater_ab;
   logic greater_bc;

   // Instantiate two gcd_top instances
   gcd_top #(.WIDTH(WIDTH)) gcd_top1 (
      .clk(clk),
      .rst(rst),
      .go(go),
      .A(A),
      .B(B),
      .OUT(x_gcd_out1)
   );

   gcd_top #(.WIDTH(WIDTH)) gcd_top2 (
      .clk(clk),
      .rst(rst),
      .go(go),
      .A(B),
      .B(C),
      .OUT(x_gcd_out2)
   );

   // Compute final GCD
   gcd_top #(.WIDTH(WIDTH)) gcd_final (
      .clk(clk),
      .rst(rst),
      .go(go),
      .A(x_gcd_out1),
      .B(x_gcd_out2),
      .OUT(final_out),
      .done(done)
   );

endmodule

// The original gcd_top module
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
      .OUT               (OUT)                // Output GCD result
   );
endmodule

// Control path module for GCD computation FSM
module gcd_controlpath (
   input                    clk,               // Clock signal
   input                    rst,               // Active High Synchronous reset
   input                    go,                // Start GCD calculation signal
   input                    equal,             // From Datapath: A_ff == B_ff
   input                    greater_than,      // From Datapath: A_ff > B_ff
   output logic [1:0]       controlpath_state, // Current state of FSM
   output logic             done               // Indicates completion of GCD calculation
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [1:0] next_state;  // Next state of FSM

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff, subtract B_ff from A_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff, subtract A_ff from B_ff

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
                // In state S1, computation is done, output the result
                OUT  <= A_ff;
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
            // In state S0, compare initial input values A and B
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A >  B)? 1'b1 : 1'b0;
          end
          default: begin
            // In other states, compare the current values in registers A_ff and B_ff
            equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
            greater_than = (A_ff >  B_ff)? 1'b1 : 1'b0;
          end
      endcase
   end
endmodule

// Datapath module for GCD computation
module gcd_datapath  #(
   parameter WIDTH = 4                           // Bit-width of operands
   )(
   input                     clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input  [WIDTH-1:0]        A,                  // Input operand A
   input  [WIDTH-1:0]        B,                  // Input operand B
   input  [1:0]              controlpath_state,  // Current state from control path
   output logic              equal,              // Signal indicating A_ff == B_ff
   output logic              greater_than        // Signal indicating A_ff > B_ff
   );

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization state
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff, subtract B_ff from A_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff, subtract A_ff from B_ff

   // Sequential logic to update registers based on controlpath_state
   always_comb begin
      case(controlpath_state)
         S0: begin
                  A_ff <= A;
                  B_ff <= B;
                end
                equal        = (A == B)? 1'b1 : 1'b0;
                greater_than  = (A >  B)? 1'b1 : 1'b0;
         S1: begin
                  OUT  <= A_ff;
               end
               greater_than  = (A_ff >  B_ff)? 1'b1 : 1'b0;
         S2: begin
                  if (greater_than)
                     A_ff <= A_ff - B_ff;
                end
                equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
                greater_than  = (A_ff >  B_ff)? 1'b1 : 1'b0;
         S3: begin
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
            // In state S0, compare initial input values A and B
            equal        = (A == B)? 1'b1 : 1'b0;
            greater_than = (A >  B)? 1'b1 : 1'b0;
          end
         default: begin
            // In other states, compare the current values in registers A_ff and B_ff
            equal        = (A_ff == B_ff)? 1'b1 : 1'b0;
            greater_than = (A_ff >  B_ff)? 1'b1 : 1'b0;
          end
      endcase
   end
endmodule
