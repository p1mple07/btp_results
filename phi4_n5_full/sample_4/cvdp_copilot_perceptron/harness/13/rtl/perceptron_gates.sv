rtl/perceptron_gates.sv
------------------------------------------------------------
module perceptron_gates (
   input  logic clk,                // Posedge clock
   input  logic rst_n,              // Negedge reset
   input  logic signed [3:0] x1,    // First Input of the Perceptron
   input  logic signed [3:0] x2,    // Second Input of the Perceptron
   input  logic learning_rate,      // Learning rate (alpha)
   input  logic signed [3:0] threshold, // Threshold value
   input  logic [1:0] gate_select,  // Gate selection for target values
   output logic signed [3:0] percep_w1, // Trained Weight 1 
   output logic signed [3:0] percep_w2, // Trained Weight 2
   output logic signed [3:0] percep_bias, // Trained Bias
   output logic [3:0] present_addr, // Current address in microcode ROM
   output logic stop,              // Condition to indicate no learning has occurred (i.e. no weight change between iterations)
   output logic [2:0] input_index, // Tracks the current target value selected during an iteration
   output logic signed [3:0] y_in, // Calculated Response
   output logic signed [3:0] y,    // Calculated Response after thresholding
   output logic signed [3:0] prev_percep_wt_1, // Weight 1 during a previous iteration
   output logic signed [3:0] prev_percep_wt_2, // Weight 2 during a previous iteration
   output logic signed [3:0] prev_percep_bias // Bias during a previous iteration
);

   //-------------------------------------------------------------------------
   // Microcode ROM and Control Signals
   //-------------------------------------------------------------------------
   logic [7:0] microcode_rom [0:5];
   logic [3:0]  next_addr;
   logic [3:0]  train_action;
   logic [3:0]  microcode_addr;
   logic [15:0] microinstruction;
   logic signed [3:0] t1, t2, t3, t4;
   
   // Instantiate the gate_target module to get target values for each gate
   gate_target dut (
       .gate_select(gate_select),
       .o_1(t1),
       .o_2(t2),
       .o_3(t3),
       .o_4(t4)
   );

   //-------------------------------------------------------------------------
   // Register Declarations for Perceptron Weights, Bias and Updates
   //-------------------------------------------------------------------------
   logic signed [3:0] percep_wt_1_reg;
   logic signed [3:0] percep_wt_2_reg;
   logic signed [3:0] percep_bias_reg;

   // Internal signals for perceptron learning
   logic signed [3:0] target;
   logic signed