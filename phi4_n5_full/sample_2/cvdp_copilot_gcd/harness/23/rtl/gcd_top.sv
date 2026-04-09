module gcd_top #(
   parameter WIDTH = 4
)(
   input                     clk,   // Clock signal
   input                     rst,   // Active High Synchronous reset signal
   input  [WIDTH-1:0]        A,     // Input operand A
   input  [WIDTH-1:0]        B,     // Input operand B
   input                     go,    // Start signal to begin GCD computation
   output logic  [WIDTH-1:0] OUT,   // Output for the GCD result
   output logic              done   // Signal to indicate completion of computation
);

   // Control state bus (4-bit wide to accommodate multiple steps)
   wire [3:0] controlpath_state;

   // Wires from datapath outputs (used by control FSM)
   wire equal;
   wire a_even;
   wire b_even;
   wire a_gt_b;
   wire a_is_zero;
   wire b_is_zero;

   // Instantiate the control path module (modified to use Stein’s algorithm)
   gcd_controlpath gcd_controlpath_inst (
      .clk               (clk),
      .rst               (rst),
      .go                (go),
      .equal             (equal),
      .a_even            (a_even),
      .b_even            (b_even),
      .a_gt_b            (a_gt_b),
      .a_is_zero         (a_is_zero),
      .b_is_zero         (b_is_zero),
      .controlpath_state (controlpath_state),
      .done              (done)
   );

   // Instantiate the data path module (modified to implement Stein’s algorithm)
   gcd_datapath
   #( .WIDTH(WIDTH)
   ) gcd_datapath_inst (
      .clk               (clk),
      .rst               (rst),
      .A                 (A),
      .B                 (B),
      .controlpath_state (controlpath_state),
      .equal             (equal),
      .a_even            (a_even),
      .b_even            (b_even),
      .a_gt_b            (a_gt_b),
      .OUT               (OUT)
   );
endmodule