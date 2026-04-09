module lcm_3_ip #(
   parameter WIDTH = 4                    // Input bit-width
)(
   input                         clk,     // Clock signal. The design should be synchronized to the positive edge of this clock signal
   input                         rst,     // Active high Synchronous reset signal
   input  [WIDTH-1:0]            A,       // WIDTH bit input
   input  [WIDTH-1:0]            B,       // WIDTH bit input
   input  [WIDTH-1:0]            C,       // WIDTH bit input
   input                         go,      // Active high Start signal for LCM computation
   output logic  [3*WIDTH-1:0]   OUT,     // Computed LCM. 3*WIDTH bits wide
   output logic                  done     // Signal indicating that the computation is complete
);

   //-------------------------------------------------------------------------
   // Compute the intermediate products. Note that:
   //   prod_AB, prod_BC, prod_CA are 2*WIDTH bits wide (to hold A*B, etc.)
   //   prod_ABC is 3*WIDTH bits wide (to hold A*B*C)
   //-------------------------------------------------------------------------
   wire [2*WIDTH-1:0] prod_AB;
   wire [2*WIDTH-1:0] prod_BC;
   wire [2*WIDTH-1:0] prod_CA;
   wire [3*WIDTH-1:0] prod_ABC;

   assign prod_AB  = A * B;
   assign prod_BC  = B * C;
   assign prod_CA  = C * A;
   assign prod_ABC = A * B * C;

   //-------------------------------------------------------------------------
   // Use the existing gcd_3_ip module to compute the GCD of the three products.
   // Since the products are 2*WIDTH bits wide, instantiate gcd_3_ip with
   // parameter WIDTH set to 2*WIDTH.
   //-------------------------------------------------------------------------
   wire [2*WIDTH-1:0] gcd_val;
   wire               gcd_done;

   gcd_3_ip #(.WIDTH(2*WIDTH))
   gcd_inst (
      .clk(clk),
      .rst(rst),
      .A(prod_AB),
      .B(prod_BC),
      .C(prod_CA),
      .go(go),
      .OUT(gcd_val),
      .done(gcd_done)
   );

   //-------------------------------------------------------------------------
   // LCM Computation Logic:
   // According to the formula:
   //   LCM(A,B,C) = (A * B * C) / GCD(A*B, B*C, C*A)
   //
   // The division is performed 2 clock cycles after the gcd_3_ip module asserts
   // its done signal. The delay logic ensures that only 2 extra clock cycles of 
   // latency are added.
   //-------------------------------------------------------------------------
   reg [1:0] delay_counter;
   reg       start_delay;
   reg [3*WIDTH-1:0] lcm_reg;
   reg       gcd_done_r;  // Register to capture the previous value of gcd_done

   always_ff @(posedge clk) begin
      if (rst) begin
         delay_counter <= 0;
         start_delay   <= 0;
         lcm_reg       <= 0;
         done          <= 0;
         gcd_done_r    <= 0;
      end
      else begin
         // Capture the previous state of gcd_done to detect its rising edge
         gcd_done_r <= gcd_done;

         // When go is active and a rising edge on gcd_done is detected, start delay counter
         if (go && (gcd_done && !gcd_done_r))
            start_delay <= 1;

         // Delay counter: wait 2 clock cycles after gcd_done before computing LCM
         if (start_delay) begin
            if (delay_counter < 2)
               delay_counter <= delay_counter + 1;
            else begin
               // Compute LCM = (A * B * C) / GCD(A*B, B*C, C*A)
               lcm_reg <= prod_ABC / gcd_val;
               done    <= 1;  // Assert done for one clock cycle
               delay_counter <= 0;
               start_delay <= 0;
            end
         end
         else begin
            done    <= 0;
            delay_counter <= 0;
         end
      end
   end

   //-------------------------------------------------------------------------
   // Update the OUT signal only when done is asserted. Otherwise, OUT retains 
   // its previous value.
   //-------------------------------------------------------------------------
   always_ff @(posedge clk) begin
      if (rst)
         OUT <= 0;
      else if (done)
         OUT <= lcm_reg;
   end

endmodule
//------------------------------------------------------------------------------------------------------------------

// Existing gcd_3_ip module (unchanged)
module gcd_3_ip #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input  [WIDTH-1:0]        C,
   input                     go,
   output logic  [WIDTH-1:0] OUT,
   output logic              done
);

   // GCD is calculated for AB and BC in parallel.
   logic [WIDTH-1:0] gcd_ab;
   logic [WIDTH-1:0] gcd_bc;
   logic             go_abc;
   logic             done_ab;
   logic             done_bc;
   logic             done_ab_latched;
   logic             done_bc_latched;

   gcd_top
   #(.WIDTH(WIDTH))
   gcd_A_B_inst (
      .clk(clk),
      .rst(rst),
      .A(A),
      .B(B),
      .go(go),
      .OUT(gcd_ab),
      .done(done_ab)
   );

   gcd_top
   #(.WIDTH(WIDTH))
   gcd_B_C_inst (
      .clk(clk),
      .rst(rst),
      .A(B),
      .B(C),
      .go(go),
      .OUT(gcd_bc),
      .done(done_bc)
   );

   gcd_top
   #(.WIDTH(WIDTH))
   gcd_ABC_inst (
      .clk(clk),
      .rst(rst),
      .A(gcd_ab),
      .B(gcd_bc),
      .go(go_abc),
      .OUT(OUT),
      .done(done)
   );

   always_ff @ (posedge clk) begin
      if (rst) begin
         done_ab_latched    <= 0;
         done_bc_latched    <= 0;
      end
      else begin
         if (done_ab)
            done_ab_latched <= done_ab;
         else if (go_abc)
            done_ab_latched <= 0;

         if (done_bc)
            done_bc_latched <= done_bc;
         else if (go_abc)
            done_bc_latched <= 0;
      end
   end

   assign go_abc = done_ab_latched & done_bc_latched;

endmodule
//------------------------------------------------------------------------------------------------------------------

// Existing gcd_top module (unchanged)
module gcd_top #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input                     go,
   output logic  [WIDTH-1:0] OUT,
   output logic              done
);

   // Internal signals to communicate between control path and data path
   logic equal;
   logic greater_than;
   logic [1:0] controlpath_state;

   // Instantiate the control path module
   gcd_controlpath gcd_controlpath_inst (
      .clk(clk),
      .rst(rst),
      .go(go),
      .equal(equal),
      .greater_than(greater_than),
      .controlpath_state(controlpath_state),
      .done(done)
   );

   // Instantiate the data path module
   gcd_datapath
   #(.WIDTH(WIDTH))
   gcd_datapath_inst (
      .clk(clk),
      .rst(rst),
      .A(A),
      .B(B),
      .controlpath_state(controlpath_state),
      .equal(equal),
      .greater_than(greater_than),
      .OUT(OUT)
   );
endmodule
//------------------------------------------------------------------------------------------------------------------

// Existing gcd_datapath module (unchanged)
module gcd_datapath  #(
   parameter WIDTH = 4
)(
   input                     clk,
   input                     rst,
   input  [WIDTH-1:0]        A,
   input  [WIDTH-1:0]        B,
   input  [1:0]              controlpath_state,
   output logic              equal,
   output logic              greater_than,
   output logic  [WIDTH-1:0] OUT
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
   always_ff @ (posedge clk) begin
      if (rst) begin
         A_ff <= 'b0;
         B_ff <= 'b0;
         OUT  <= 'b0;
      end
      else begin
         case (controlpath_state)
            S0: begin
               A_ff <= A;
               B_ff <= B;
            end
            S1: begin
               OUT  <= A_ff;
            end
            S2: begin
               if (greater_than)
                  A_ff <= A_ff - B_ff;
            end
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
            equal        = (A == B) ? 1'b1 : 1'b0;
            greater_than = (A >  B) ? 1'b1 : 1'b0;
         end
         default: begin
            equal        = (A_ff == B_ff) ? 1'b1 : 1'b0;
            greater_than = (A_ff >  B_ff) ? 1'b1 : 1'b0;
         end
      endcase
   end
endmodule
//------------------------------------------------------------------------------------------------------------------

// Existing gcd_controlpath module (unchanged)
module gcd_controlpath (
   input                    clk,
   input                    rst,
   input                    go,
   input                    equal,
   input                    greater_than,
   output logic [1:0]       controlpath_state,
   output logic             done
);

   // Internal state registers
   logic [1:0] curr_state;  // Current state of FSM
   logic [1:0] next_state;  // Next state of FSM

   // State encoding
   localparam S0 = 2'd0;    // State 0: Initialization or waiting for 'go' signal
   localparam S1 = 2'd1;    // State 1: Computation complete
   localparam S2 = 2'd2;    // State 2: A_ff > B_ff
   localparam S3 = 2'd3;    // State 3: B_ff > A_ff

   // State latching logic: Update current state on clock edge
   always_ff @ (posedge clk) begin
      if (rst)
         curr_state <= S0;
      else
         curr_state <= next_state;
   end

   // State transition logic: Determine next state based on current state and inputs
   always_comb begin
      case(curr_state)
         S0: begin
             if(!go)
                next_state = S0;
             else if (equal)
                next_state = S1;
             else if (greater_than)
                next_state = S2;
             else
                next_state = S3;
         end
         S1: begin
             next_state = S0;
         end
         S2: begin
             if(equal)
                next_state = S1;
             else if (greater_than)
                next_state = S2;
             else
                next_state = S3;
         end
         S3: begin
             if (equal)
                next_state = S1;
             else if (greater_than)
                next_state = S2;
             else
                next_state = S3;
         end
         default: begin
             next_state = S0;
         end
      endcase
   end

   // Output logic: Generate 'done' signal when computation is complete
   always_ff @ (posedge clk) begin
     if(rst)
        done <= 1'b0;
     else
        done <= (curr_state == S1);
   end

   // Assign current state to output for datapath
   assign controlpath_state = curr_state;

endmodule