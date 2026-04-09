module perceptron_gates (
   input  logic clk,// Posedge clock
   input  logic rst_n,// Negedge reset
   input  logic signed [3:0] x1, // First Input of the Perceptron
   input  logic signed [3:0] x2, // Second Input of the Perceptron
   input  logic learning_rate, // Learning rate (alpha)
   input  logic signed [3:0] threshold, // Threshold value
   input  logic [1:0] gate_select, // Gate selection for target values
   output logic signed [3:0] percep_w1, // Trained Weight 1 
   output logic signed [3:0] percep_w2, // Trained Weight 2
   output logic signed [3:0] percep_bias, // Trained Bias
   output logic [3:0] test_percep_result, // Number of correct test cases
   output logic [3:0] test_percep_done, // Test completion status
   output logic signed [3:0] test_percep_x1, // Test input 1
   output logic signed [3:0] test_percep_x2, // Test input 2
   output logic signed [3:0] test_percep_output, // Actual test output
   output logic signed [3:0] test_percep_present_state // Present state of Testing ROM
);

   logic [15:0] microcode_rom [0:5];
   logic [3:0]  next_addr;
   logic [3:0]  train_action;
   logic [3:0]  test_action;
   logic [3:0]  microcode_addr;
   logic [3:0]  gate_target;
   logic [7:0]  epoch_counter;
   logic [2:0]  input_index;
   logic [3:0]  prev_percep_wt_1, prev_percep_wt_2, prev_percep_bias;
   logic [3:0]  target;
   logic [3:0]  prev_wt1_update, prev_wt2_update, prev_bias_update;
   logic [3:0]  wt1_update, wt2_update, bias_update;
   logic [3:0]  stop, input_index;
   logic [2:0]  input_index;
   logic [3:0]  prev_percep_wt_1_reg, prev_percep_wt_2_reg, prev_percep_bias_reg;
   logic [3:0]  percep_wt_1_reg, percep_wt_2_reg, percep_bias_reg;
   logic signed [3:0] percep_w1_reg, percep_w2_reg, percep_bias_reg;
   logic signed [3:0] test_percep_w1_reg, test_percep_w2_reg, test_percep_bias_reg;
   logic signed [3:0] percep_wt_1_reg, percep_wt_2_reg, percep_bias_reg;
   logic signed [3:0] y_in, y, y_in;
   logic signed [3:0] prev_percep_wt_1_update, prev_perce_wt_2_update, prev_bias_update;
   logic signed [3:0] wt1_update, wt2_update, bias_update;
   logic [7:0] epoch_counter;
   logic [2:0] input_index;
   logic [3:0] present_addr;
   logic [3:0] stop, input_index;
   logic [3:0] prev_percep_wt_1_update, prev_wt1_update;
   logic [3:0] prev_perce_wt_2_update, prev_wt2_update;
   logic [3:0] prev_bias_update, prev_bias_update;
   logic [3:0] wt1_update, wt1_update;
   logic [3:0] wt2_update, wt2_update;
   logic [3:0] bias_update, bias_update;
   logic [7:0] epoch_counter;
   logic [2:0] input_index;
   logic [3:0] prev_perce_wt_1_reg, prev_perce_wt_2_reg, prev_perce_bias_reg;
   logic signed [3:0] percep_wt_1_reg, percep_wt_2_reg, percep_bias_reg;
   logic signed [3:0] percep_w1_reg, percep_w2_reg, percep_bias_reg;

   // Testing related signals
   logic [3:0] test_percep_present_state;
   logic [3:0] test_percep_output;
   logic [3:0] test_percep_result;
   logic [3:0] test_percep_done;
   logic [3:0] test_percep_x1;
   logic [3:0] test_percep_x2;

   // Testing microcode
   always@(*) begin
      case (microcode_addr)
         0:  begin 
             percep_wt_1 = 4'd0;
             percep_wt_2 = 4'd0;
             percep_bias_reg = 4'd0;
             stop = 1'b0;
             input_index = 4'd0;
         end
         1 : begin
             y_in = percep_bias_reg + (x1 * percep_wt_1) + (x2 * percep_wt_2);
             if (y_in > threshold)
                y = 4'd1;
             else if (y_in >= -threshold && y_in <= threshold)
                y = 4'd0;
             else
                y = -4'd1;
             
             percep_wt_1  = percep_wt_1  + 4'd0;
             percep_wt_2  = percep_wt_2  + 4'd0;
             percep_bias_reg  = percep_bias_reg  + 4'd0;
             
             prev_wt1_update  = prev_wt1_update  + 4'd0;
             prev_wt2_update  = prev_wt2_update  + 4'd0;
             prev_bias_update  = prev_bias_update  + 4'd0;
             
             input_index = input_index + 0;
             stop = 0;
             target = 0;
         end
         // Add more cases for testing as needed
      default : begin
             percep_wt_1_reg = percep_wt_1_reg + 4'd0;
             percep_wt_2_reg = percep_wt_2_reg + 4'd0;
             percep_bias_reg = percep_bias_reg + 4'd0;
             y_in = y_in + 4'd0;
             y = y + 4'd0;
             stop = 1'b0;
             input_index = 4'd0;
      endcase
   end

   // Add testing related outputs
   assign test_percep_result = 4'd0;
   assign test_percep_done = 1'b0;
   assign test_percep_x1 = 4'd0;
   assign test_percep_x2 = 4'd0;
   assign test_percep_output = 4'd0;
   assign test_percep_present_state = 4'd0;

   // Add testing related control lines
   input [1:0] test_control;
   output [1:0] test Ready;

   // Modify the microcode address selection to include testing
   microcode_addr = microcode_addr + test_control[1:0];
   // Add new testing address for microcode ROM
   microcode_addr = microcode_addr + 16'b0;