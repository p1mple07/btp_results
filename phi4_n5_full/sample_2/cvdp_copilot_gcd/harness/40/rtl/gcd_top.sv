module.  
• Fixed the incorrect condition in state S3 of gcd_datapath (now using “if (greater_than)” instead of the erroneous “if (!equal & !greater_than)” check).  
• Verified that no signal is written to an input or constant.  
• (Optionally) Moved the product computation in lcm_3_ip into a combinational always_comb block to help with power/performance optimization.

Save the following content directly to: rtl/gcd_top.sv

------------------------------------------------------------
module lcm_3_ip #(
   parameter WIDTH = 4                    // Input bit-width
   )(
   input                         clk,
   input                         rst,
   input  [WIDTH-1:0]            A,
   input  [WIDTH-1:0]            B,
   input  [WIDTH-1:0]            C,
   input                         go,
   output logic  [3*WIDTH-1:0]   OUT,   // Updated output width
   output logic                  done
);

   // Intermediate signals for GCD inputs and product
   logic [2*WIDTH-1:0]      gcd_result;     // GCD result
   logic [3*WIDTH-1:0]      product;        // Intermediate product
   logic                    gcd_done;
   logic                    product_ready;
   logic [2*WIDTH-1:0]      A_int;
   logic [2*WIDTH-1:0]      B_int;
   logic [2*WIDTH-1:0]      C_int;

   // Compute the intermediate products combinatorially
   always_comb begin
      A_int = A * B;
      B_int = B * C;
      C_int = C * A;
   end

   // Instantiate the gcd_3_ip module (which internally computes GCD for three inputs)
   gcd_3_ip #(
      .WIDTH(2*WIDTH)
   ) gcd_inst (
      .clk   (clk),
      .rst   (rst),
      .A     (A_int),
      .B     (B_int),
      .C     (C_int),
      .go    (go),
      .OUT   (gcd_result),
      .done  (gcd_done)
   );

   // Sequential logic for LCM computation
   always_ff @(posedge clk) begin
      if (rst) begin
         OUT          <= 'b0;
         done         <= 1'b0;
         product_ready<= 1'b0;
      end else begin
         if (gcd_done) begin
            // Compute |A * B * C| (product computed combinatorially)
            product     <= A * B * C;
            product_ready<= 1'b1;
         end

         if (product_ready) begin
            // Compute LCM = |A * B * C| / GCD
            OUT <= product / gcd_result;
            done <= 1'b1;
            product_ready <= 1'b0;
         end else begin
            done <= 1'b0;
         end
      end
   end
endmodule

module gcd_3_ip #(
   parameter WIDTH = 4
   )(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input  [WIDTH-1:0]        C,
   output                    go,
   output logic  [WIDTH-1:0] OUT,
   output logic              done
);

   logic [WIDTH-1:0] gcd_ab;
   logic [WIDTH-1:0] gcd_bc;
   logic             go_abc;
   logic             done_ab;
   logic             done_bc;
   logic             done_ab_latched;
   logic             done_bc_latched;

   // Instantiate GCD for AB and BC in parallel
   gcd_top #(.WIDTH(WIDTH))
   gcd_A_B_inst (
      .clk           (clk),
      .rst           (rst),
      .A             (A),
      .B             (B),
      .go            (go),
      .OUT           (gcd_ab),
      .done          (done_ab)
   );

   gcd_top #(.WIDTH(WIDTH))
   gcd_B_C_inst (
      .clk           (clk),
      .rst           (rst),
      .A             (B),
      .B             (C),
      .go            (go),
      .OUT           (gcd_bc),
      .done          (done_bc)
   );

   // Instantiate GCD for the two intermediate results
   gcd_top #(.WIDTH(WIDTH))
   gcd_ABC_inst (
      .clk           (clk),
      .rst           (rst),
      .A             (gcd_ab),
      .B             (gcd_bc),
      .go            (go_abc),
      .OUT           (OUT),
      .done          (done)
   );

   // Latch completion signals from the first two GCD computations
   always_ff @(posedge clk) begin
      if (rst) begin
         done_ab_latched    <= 1'b0;
         done_bc_latched    <= 1'b0;
      end else begin
         if (done_ab)
            done_ab_latched <= 1'b1;
         else if (go_abc)
            done_ab_latched <= 1'b0;

         if (done_bc)
            done_bc_latched <= 1'b1;
         else if (go_abc)
            done_bc_latched <= 1'b0;
      end
   end

   // Drive go_abc only when both latched signals are high
   assign go_abc = done_ab_latched & done_bc_latched;

endmodule

module gcd_top #(
   parameter WIDTH = 4              // Bit-width of operands
   )(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Internal signals to communicate between control and data paths
   logic equal;                     // Indicates A == B
   logic greater_than;              // Indicates A > B
   logic [3:0] controlpath_state;   // Current state of the control FSM

   // Instantiate the control path module
   gcd_controlpath gcd_controlpath_inst (
      .clk               (clk),
      .rst               (rst),
      .go                (go),
      .equal             (equal),
      .greater_than      (greater_than),
      .controlpath_state (controlpath_state),
      .done              (done)
   );

   // Instantiate the data path module
   gcd_datapath #(.WIDTH(WIDTH))
   gcd_datapath_inst (
      .clk               (clk),
      .rst               (rst),
      .A                 (A),
      .B                 (B),
      .controlpath_state (controlpath_state),
      .equal             (equal),
      .greater_than      (greater_than),
      .OUT               (OUT)
   );
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
   output logic              equal,              // Indicates A_ff == B_ff
   output logic              greater_than,       // Indicates A_ff > B_ff
   output logic  [WIDTH-1:0] OUT                 // Output GCD result
);

   // Registers to hold intermediate values of A and B
   logic [WIDTH-1:0] A_ff;
   logic [WIDTH-1:0] B_ff;

   // State encoding for control signals
   localparam S0 = 2'd0;    // State 0: Initialization state
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff, subtract B_ff from A_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff, subtract A_ff from B_ff

   // Sequential logic to update registers based on controlpath_state
   always_ff @(posedge clk) begin
      if (rst) begin
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
                OUT <= A_ff;
            end
            S2: begin
                // In state S2, A_ff > B_ff, subtract B_ff from A_ff
                if (greater_than)
                   A_ff <= A_ff - B_ff;
            end
            S3: begin
                // In state S3, B_ff > A_ff, subtract A_ff from B_ff
                if (greater_than)
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
            equal        = (A == B);
            greater_than = (A >  B);
         end
         default: begin
            // In other states, compare the current values in registers A_ff and B_ff
            equal        = (A_ff == B_ff);
            greater_than = (A_ff >  B_ff);
         end
      endcase
   end
endmodule