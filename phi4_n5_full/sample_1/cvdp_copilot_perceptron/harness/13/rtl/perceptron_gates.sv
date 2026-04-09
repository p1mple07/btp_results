rtl/perceptron_gates.sv
------------------------------------------------------------
module perceptron_gates (
   input  logic clk,              // Posedge clock
   input  logic rst_n,            // Negedge reset
   input  logic signed [3:0] x1,  // First Input of the Perceptron
   input  logic signed [3:0] x2,  // Second Input of the Perceptron
   input  logic learning_rate,    // Learning rate (alpha)
   input  logic signed [3:0] threshold, // Threshold value
   input  logic [1:0] gate_select, // Gate selection for target values
   output logic signed [3:0] percep_w1, // Trained Weight 1 
   output logic signed [3:0] percep_w2, // Trained Weight 2
   output logic signed [3:0] percep_bias, // Trained Bias
   output logic [3:0] present_addr, // Current address in microcode ROM
   output logic stop, // Condition to indicate no learning has occurred (i.e. no weight change between iterations)
   output logic [2:0] input_index, // Vector to track the selection of target for a given input combination for a gate
   output logic signed [3:0] y_in, // Calculated Response
   output logic signed [3:0] y,   // Calculated Response obtained by comparing y_in against a threshold value
   output logic signed [3:0] prev_percep_wt_1, // Value of Weight 1 during a previous iteration
   output logic signed [3:0] prev_percep_wt_2, // Value of Weight 2 during a previous iteration
   output logic signed [3:0] prev_percep_bias  // Value of Bias during a previous iteration
);

   // Microcode ROM and related signals
   logic [7:0] microcode_rom [0:5];
   logic [3:0] next_addr;
   logic [3:0] train_action;
   logic [3:0] microcode_addr;
   logic [15:0] microinstruction;

   // Target values from gate_target module
   logic signed [3:0