rtl/perceptron_gates.sv
------------------------------------------------------------
module perceptron_gates (
   input  logic clk,               // Posedge clock
   input  logic rst_n,             // Negedge reset
   input  logic signed [3:0] x1,   // First Input of the Perceptron (Bipolar: 4'd1 or -4'd1)
   input  logic signed [3:0] x2,   // Second Input of the Perceptron (Bipolar: 4'd1 or -4'd1)
   input  logic learning_rate,     // Learning rate (alpha)
   input  logic signed [3:0] threshold, // Threshold value
   input  logic [1:0] gate_select, // Gate selection for target values
   output logic signed [3:0] percep_w1, // Trained Weight 1 
   output logic signed [3:0] percep_w2, // Trained Weight 2
   output logic signed [3:0] percep_bias, // Trained Bias
   output logic [3:0] present_addr, // Current address in microcode ROM
   output logic stop,              // Stop condition flag
   output logic [2:0] input_index, // Iterator for target selection (0 to 3)
   output logic signed [3:0] y_in, // Calculated response before thresholding
   output logic signed [3:0] y,    // Calculated response after thresholding (1,0,-1)
   output logic signed [3:0] prev_percep_wt_1, // Weight 1 from previous iteration
   output logic signed [3:0] prev_percep_wt_2, // Weight 2 from previous iteration
   output logic signed [3:0] prev_percep_bias  // Bias from previous iteration
);

   // Microcode ROM: 6 locations, each 8 bits (4-bit next_addr, 4-bit train_action)
   logic [7:0] microcode_rom [0:5];
   logic [3:0]  next_addr;
   logic [3:0]  train_action;
   logic [3:0]  microcode_addr;
   logic [15:0] microinstruction;

   // Targets from gate_target submodule
   logic signed [3:0] t1, t2, t3, t4;
   logic signed [3:0] target; // Computed target based on input_index

   // Instantiate gate_target module
   gate_target dut (
       .gate_select(gate_select),
       .o_1(t1),
       .o_2(t2),
       .o_3(t3),
       .o_4(t4)
   );

   // Registers for perceptron weights, bias and update values
   logic signed [3:0] percep_wt_1_reg;
   logic signed [3:0] percep_wt_2_reg;
   logic signed [3:0] percep_bias_reg;

   logic signed [3:0] wt1_update;
   logic signed [3:0] wt2_update;
   logic signed [3:0] bias_update;

   logic signed [3:0] prev_wt1_update;
   logic signed [3:0] prev_wt2_update;
   logic signed [3:0] prev_bias_update;

   logic [7:0] epoch_counter; // 8-bit epoch counter

   // Connect output ports to internal registers
   assign percep_w1   = percep_wt_1_reg;
   assign percep_w2   = percep_wt_2_reg;
   assign percep_bias = percep_bias_reg;
   assign prev_percep_wt_1 = prev_wt1_update;
   assign prev_percep_wt_2 = prev_wt2_update;
   assign prev_percep_bias  = prev_bias_update;

   // Microcode ROM initialization
   initial begin 
      microcode_rom[0] = 8'b0001_0000; // next_addr=1, train_action=0
      microcode_rom[1] = 8'b0010_0001; // next_addr=2, train_action=1
      microcode_rom[2] = 8'b0011_0010; // next_addr=3, train_action=2
      microcode_rom[3] = 8'b0100_0011; // next_addr=4, train_action=3
      microcode_rom[4] = 8'b0101_0100; // next_addr=5, train_action=4
      microcode_rom[5] = 8'b0000_0101; // next_addr=0, train_action=5
   end  

   // Combinational block to extract microinstruction fields
   always_comb begin
      microinstruction = microcode_rom[microcode_addr];
      next_addr        = microinstruction[7:4];
      train_action     = microinstruction[3:0];
   end

   // ------------------------------------------------------------------
   // Combinational Next-State Logic for Perceptron Training
   // We define intermediate "next" signals that will be registered on the next clock.
   // ------------------------------------------------------------------
   logic signed [3:0] next_percep_wt_1;
   logic signed [3:0] next_percep_wt_2;
   logic signed [3:0] next_percep_bias;
   logic [2:0] next_input_index;
   logic next_stop;
   logic signed [3:0] next_y_in;
   logic signed [3:0] next_y;
   logic signed [3:0] next_prev_wt1_update;
   logic signed [3:0] next_prev_wt2_update;
   logic signed [3:0] next_prev_bias_update;
   logic signed [3:0] next_wt1_update;
   logic signed [3:0] next_wt2_update;
   logic signed [3:0] next_bias_update;
   logic [7:0] next_epoch_counter;
   logic signed [3:0] next_target;

   always_comb begin
      // Default: hold current values
      next_percep_wt_1    = percep_wt_1_reg;
      next_percep_wt_2    = percep_wt_2_reg;
      next_percep_bias    = percep_bias_reg;
      next_input_index    = input_index;
      next_stop           = stop;
      next_y_in           = y_in;
      next_y              = y;
      next_prev_wt1_update= prev_wt1_update;
      next_prev_wt2_update= prev_wt2_update;
      next_prev_bias_update= prev_bias_update;
      next_wt1_update     = wt1_update;
      next_wt2_update     = wt2_update;
      next_bias_update    = bias_update;
      next_epoch_counter  = epoch_counter;
      next_target         = target;

      case (train_action)
         4'd0: begin
            // Initialization: set weights, bias and update values to zero.
            next_percep_wt_1    = 4'd0;
            next_percep_wt_2    = 4'd0;
            next_percep_bias    = 4'd0;
            next_stop           = 1'b0;
            next_y_in           = 4'd0;
            next_y              = 4'd0;
            next_prev_wt1_update= 4'd0;
            next_prev_wt2_update= 4'd0;
            next_prev_bias_update= 4'd0;
            next_wt1_update     = 4'd0;
            next_wt2_update     = 4'd0;
            next_bias_update    = 4'd0;
            next_epoch_counter  = 4'd0;
            next_target         = 4'd0;
         end
         4'd1: begin
            // Compute y_in and apply thresholding to get y.
            next_y_in = percep_bias_reg + (x1