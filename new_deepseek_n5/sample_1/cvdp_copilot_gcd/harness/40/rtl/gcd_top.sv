module gcd_3_ip #(
   parameter WIDTH = 4
   )(
   input                    _clk,
   input                    _rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input  [WIDTH-1:0]        C,
   output                    go,
   output logic  [WIDTH-1:0] OUT,
   output logic              done
);

   logic [2*WIDTH-1:0]      gcd_result;
   logic [3*WIDTH-1:0]      product;
   logic                    gcd_done;
   logic                    product_ready;
   logic [2*WIDTH-1:0]      A_int;
   logic [2*WIDTH-1:0]      B_int;
   logic [2*WIDTH-1:0]      C_int;

   always_comb begin
      A_int = A;
      B_int = B;
      C_int = C;
   end

   // Calculate GCD of A, B, and C
   gcd_top
   #(
      .WIDTH(2*WIDTH)
   ) gcd_inst (
      .clk   _clk,
      .rst   rst,
      .A     A_int,
      .B     B_int,
      .go    go,
      .OUT   gcd_result,
      .done  gcd_done
   );

   // Sequential logic for LCM computation
   always_ff @(posedge _clk) begin
      if (rst) begin
         product_ready <= 0;
         done <= 0;
      end else begin
         if (gcd_done) begin
            // Compute |A * B * C|
            product <= A * B * C;
            product_ready <= 1;
         end

         if (product_ready) begin
            // Compute LCM = |A * B * C| / GCD
            product <= product / gcd_result;
            done <= 1;
            product_ready <= 0;
         end else begin
            done <= 0;
         end
      end
   end
endmodule

module gcd_top #(
   parameter WIDTH = 4
   )(
   input                    _clk,
   input                    _rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input  [WIDTH-1:0]        C,
   output                    go,
   output logic  [WIDTH-1:0] OUT,
   output logic              done
);

   // Internal signals to communicate between control path and data path
   logic equal;
   logic greater_than;
   logic [WIDTH-1:0] controlpath_state;

   // Instantiate the control path module
   gcd_controlpath gcd_controlpath_inst (
      .clk               _clk,
      .rst               rst,
      .go                go,
      .equal             equal,
      .greater_than      greater_than,
      .controlpath_state controlpath_state,
      .done              done
   );

   // Instantiate the data path module
   gcd_datapath
   #( .WIDTH(WIDTH)
   ) gcd_datapath_inst (
      .clk               _clk,
      .rst               rst,
      .A                 A,
      .B                 B,
      .controlpath_state controlpath_state,
      .equal             equal,
      .greater_than      greater_than,
      .OUT               OUT
   );
endmodule


// Datapath module for GCD computation
module gcd_datapath  #(
   parameter WIDTH = 4
   )(
   input                    _clk,                // Clock signal
   input                     rst,                // Active High Synchronous reset
   input  [WIDTH-1:0]        A,                  // Input operand A
   input  [WIDTH-1:0]        B,                  // Input operand B
   input  [1:0]              controlpath_state,  // Current state from control path
   output logic              equal,              // Signal indicating A_ff == B_ff
   output logic              greater_than,       // Signal indicating A_ff > B_ff
   output logic  [WIDTH-1:0] OUT                 // Output GCD result
);

   // Internal signals to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;
   logic [WIDTH-1:0] controlpath_state_ff;

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization state
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff, subtract B_ff from A_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff, subtract A_ff from B_ff

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

// Control path module for GCD computation FSM
module gcd_controlpath (
   input                   _clk,               // Clock signal
   input                    rst,               // Active High Synchronous reset
   input                    go,                // Start GCD calculation signal
   input                    equal,             // From Datapath: A_ff equals B_ff
   input                    greater_than,      // From Datapath: A_ff is greater than B_ff
   output logic [1:0]       controlpath_state, // Current state to Datapath
   output logic             done               // Indicates completion of GCD calculation
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM

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