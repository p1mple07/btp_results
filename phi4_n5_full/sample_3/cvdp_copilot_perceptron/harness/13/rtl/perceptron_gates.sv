module perceptron_gates (
   input  logic clk,               // Posedge clock
   input  logic rst_n,             // Negedge reset
   input  logic signed [3:0] x1,   // First Input of the Perceptron
   input  logic signed [3:0] x2,   // Second Input of the Perceptron
   input  logic learning_rate,     // Learning rate (alpha)
   input  logic signed [3:0] threshold, // Threshold value
   input  logic [1:0] gate_select, // Gate selection for target values
   output logic signed [3:0] percep_w1, // Trained Weight 1 
   output logic signed [3:0] percep_w2, // Trained Weight 2
   output logic signed [3:0] percep_bias, // Trained Bias
   output logic [3:0] present_addr, // Current address in microcode ROM
   output logic stop,              // Condition to indicate no learning has occurred (i.e. no weight change)
   output logic [2:0] input_index, // Vector to track the selection of target for a given input combination
   output logic signed [3:0] y_in, // Calculated Response
   output logic signed [3:0] y,   // Calculated Response after thresholding
   output logic signed [3:0] prev_percep_wt_1, // Weight 1 during previous iteration
   output logic signed [3:0] prev_percep_wt_2, // Weight 2 during previous iteration
   output logic signed [3:0] prev_percep_bias  // Bias during previous iteration
);

   // Microcode ROM and control signals
   logic [7:0] microcode_rom [0:5];
   logic [3:0]  next_addr;
   logic [3:0]  train_action;
   logic [3:0]  microcode_addr;
   logic [15:0] microinstruction;
   logic signed [3:0] t1, t2, t3, t4;
   
   // Gate target submodule instantiation
   gate_target dut (
       .gate_select(gate_select),
       .o_1(t1),
       .o_2(t2),
       .o_3(t3),
       .o_4(t4)
   );

   // Internal registers for perceptron weights, bias and update values
   logic signed [3:0] percep_wt_1_reg;
   logic signed [3:0] percep_wt_2_reg;
   logic signed [3:0] percep_bias_reg;

   // Target and update registers
   logic signed [3:0] target;
   logic signed [3:0] prev_wt1_update;
   logic signed [3:0] prev_wt2_update;
   logic signed [3:0] prev_bias_update;
   logic signed [3:0] wt1_update;
   logic signed [3:0] wt2_update;
   logic signed [3:0] bias_update;
   logic [7:0] epoch_counter;

   // Connect previous iteration values to outputs
   assign prev_percep_wt_1 = prev_wt1_update;
   assign prev_percep_wt_2 = prev_wt2_update;
   assign prev_percep_bias = prev_bias_update;

   // Initialize the microcode ROM with 6 locations
   initial begin 
      microcode_rom[0] = 8'b0001_0000; 
      microcode_rom[1] = 8'b0010_0001; 
      microcode_rom[2] = 8'b0011_0010; 
      microcode_rom[3] = 8'b0100_0011; 
      microcode_rom[4] = 8'b0101_0100; 
      microcode_rom[5] = 8'b0000_0101; 
   end  
   
   // Combinational block to fetch microinstruction from ROM
   always @(*) begin
      microinstruction = microcode_rom[microcode_addr];
      next_addr        = microinstruction[7:4];
      train_action     = microinstruction[3:0];
   end

   // Sequential block for microcode address and reset initialization
   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         present_addr    <= 4'd0;
         microcode_addr  <= 4'd0;
         percep_wt_1_reg <= 4'd0;
         percep_wt_2_reg <= 4'd0;
         percep_bias_reg <= 4'd0;
         input_index     <= 3'd0;
         stop            <= 1'b0;
      end else begin
         present_addr    <= next_addr;
         microcode_addr  <= present_addr;
      end
   end

   // Microcode control logic: perform actions based on the train_action code
   always_comb begin
      // Default assignments to avoid latches
      percep_wt_1_reg    = percep_wt_1_reg;
      percep_wt_2_reg    = percep_wt_2_reg;
      percep_bias_reg    = percep_bias_reg;
      stop               = stop;
      y_in               = y_in;
      y                  = y;
      prev_wt1_update    = prev_wt1_update;
      prev_wt2_update    = prev_wt2_update;
      prev_bias_update   = prev_bias_update;
      wt1_update         = wt1_update;
      wt2_update         = wt2_update;
      bias_update        = bias_update;
      epoch_counter      = epoch_counter;
      input_index        = input_index;
      target             = target;
      next_addr          = next_addr;

      case (train_action)
         4'd0: begin
                  // 0: Initialization
                  percep_wt_1_reg    = 4'd0;
                  percep_wt_2_reg    = 4'd0;
                  percep_bias_reg    = 4'd0;
                  stop               = 1'b0;
                  y_in               = 4'd0;
                  y                  = 4'd0;
                  prev