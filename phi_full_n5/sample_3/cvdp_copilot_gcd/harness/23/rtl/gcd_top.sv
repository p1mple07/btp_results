module gcd_top #(
   parameter WIDTH = 4              // Parameter to define the bit-width of the input and output data
) (
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Internal signals to communicate between control path and data path
   logic equal;                     // Signal indicating A == B
   logic [1:0] factor_count;       // Count of factors of 2 removed

   // Instantiate the control path module
   gcd_controlpath gcd_controlpath_inst (
      .clk               (clk),
      .rst               (rst),
      .go                (go),
      .equal             (equal),
      .factor_count      (factor_count),
      .OUT               (OUT),
      .done              (done)
   );

   // Instantiate the data path module
   gcd_datapath
   #(
      .WIDTH(WIDTH),
      .factor_count(factor_count)
   ) gcd_datapath_inst (
      .clk               (clk),
      .rst               (rst),
      .A                 (A),
      .B                 (B),
      .equal             (equal),
      .factor_count      (factor_count),
      .OUT               (OUT)
   );

endmodule

// Control path module for GCD computation FSM using Stein's algorithm
module gcd_controlpath (
   input                    clk,
   input                    rst,
   input                    go,
   input                    equal,
   output logic [1:0]       controlpath_state,
   output logic             done
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [1:0] next_state;  // Next state of FSM

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Identifying equal inputs
   localparam S2 = 2'd2;    // State 2: Removing factors of 2
   localparam S3 = 2'd3;    // State 3: Computing GCD

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
             if(!go)
                next_state = S0;         // Remain in S0 until 'go' is asserted
             else if (equal)
                next_state = S1;         // If A == B, move to S1
             else
                next_state = S2;         // If A and B are different, move to S2
         end
         S1: begin
             // In state S1, both A and B are equal, move to S3
             next_state = S3;
         end
         S2: begin
             // In state S2, remove a factor of 2 from both A and B
             if (A & B == 0) begin
                next_state = S3;
             else if (A % 2 == 0) begin
                next_state = S2;
                factor_count <= factor_count + 1;
             end else if (B % 2 == 0) begin
                next_state = S2;
                factor_count <= factor_count + 1;
             end
         end
         S3: begin
             // In state S3, compute GCD using Stein's algorithm
             // Remove a factor of 2 from both A and B if they are even
             if (A % 2 == 0) begin
                A <= A / 2;
                if (B % 2 == 0) begin
                   B <= B / 2;
                   next_state = S2;
                end
             end
             // If A and B are odd, compute GCD of |A-B|/2 and B
             if (A > B) begin
                A <= A - B;
                next_state = S3;
             end else begin
                B <= B - A;
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
   input                     equal,             // From control path: A == B
   output logic              equal,              // Signal indicating A_ff equals B_ff
   output logic              [WIDTH-1:0] OUT,       // Output GCD result
   output logic              factor_count        // Count of factors of 2 removed
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // Sequential logic to update registers based on controlpath_state
   always_ff @ (posedge clk) begin
      if (rst) begin
         A_ff <= 'b0;
         B_ff <= 'b0;
         OUT <= 'b0;
         factor_count <= 0;
      end else begin
         case (controlpath_state)
            S0: begin
                // In state S0, load input values into registers
                A_ff <= A;
                B_ff <= B;
             end
            S1: begin
                // In state S1, both A and B are equal, move to S3
                A_ff <= 'b0;
                B_ff <= 'b0;
                next_state = S3;
             end
            S2: begin
                // In state S2, remove a factor of 2 from both A and B
                if (A % 2 == 0) begin
                   A_ff <= A_ff / 2;
                   if (B % 2 == 0) begin
                      B_ff <= B_ff / 2;
                   end
                end
                next_state = S2;
             end
            S3: begin
                // In state S3, compute GCD using Stein's algorithm
                // Remove a factor of 2 from both A and B if they are even
                if (A % 2 == 0) begin
                   A_ff <= A_ff / 2;
                end
                if (B % 2 == 0) begin
                   B_ff <= B_ff / 2;
                end
                // If A and B are odd, compute GCD of |A-B|/2 and B
                if (A > B) begin
                   A <= A - B;
                   next_state = S2;
                end else begin
                   B <= B - A;
                   next_state = S2;
                end
             end
            default: begin
                A_ff <= 'b0;
                B_ff <= 'b0;
                OUT <= 'b0;
                factor_count <= 0;
            end
         endcase
      end
   end

   // Generating control response signals for the control path FSM
   always_comb begin
      equal = (A == B)? 1'b1 : 1'b0;
   end
endmodule
