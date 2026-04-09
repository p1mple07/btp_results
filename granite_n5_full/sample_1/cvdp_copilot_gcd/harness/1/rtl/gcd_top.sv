module gcd_top #(
  parameter WIDTH = 4
) (
  // Clock & Reset
  input wire clk,     // Positive Edge Triggered
  input wire rst,     // Active High, Synchronous Reset
  
  // Input Values
  input wire [WIDTH-1:0] a,
  input wire [WIDTH-1:0] b,
  
  // Operation Control
  input wire go,
  
  // Outputs
  output reg [WIDTH-1:0] out,    // Output for the calculated GCD (unsigned).
  output reg done               // Signal that indicates when the computation is complete.
);

  // Instantiate the control path module
  gcd_controlpath #(
   .WIDTH (WIDTH)
  ) gcd_controlpath_inst (
   .clk      (clk),       // Positive Edge Triggered.
   .rst      (rst),       // Active High, Synchronous Reset.
   .go       (go),        // Active high to start the computation.
    
   .equal    (),            // Signals from the datapath indicating that A == B.
   .greater_than(), // Signals from the datapath indicating A > B.
    
   .controlpath_state (),   // State of the control path FSM.
   .out (),                     // Output for the computation.
   .done ()                       // Signal that indicates when the computation is complete.
  );
    
  // Instantiate the datapath module
  gcd_datapath #(
   .WIDTH (WIDTH)
  ) gcd_datapath_inst (
   .clk      (clk),       // Positive Edge Triggered.
   .rst      (rst),       // Active High, Synchronous Reset.
   .a         (a),         // Input value A (unsigned and non-zero).
   .b         (b),         // Input value B (unsigned and non-zero).
   .equal    (equal),    // Signal indicating that A == B.
   .greater_than (greater_than),    // Signal indicating that A > B.
    
   .controlpath_state (controlpath_state),   // State of the control path FSM.
   .out         (out),         // Output for the computation.
   .done         ()                        // Signal that indicates that the computation is complete.
  );
endmodule