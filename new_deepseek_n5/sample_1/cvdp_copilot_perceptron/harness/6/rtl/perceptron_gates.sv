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
    output logic [3:0] test_percep_w1, // Trained Weight 1 during Testing
    output logic [3:0] test_percep_w2, // Trained Weight 2 during Testing
    output logic [3:0] test_percep_bias, // Trained Bias during Testing
    output logic signed [3:0] y_in, // Calculated Response
    output logic signed [3:0] y, // Calculated Response obtained by comparing y_in against a threshold value
    output logic signed [3:0] prev_percep_wt_1,// Value of Weight 1 during a previous iteration
    output logic signed [3:0] prev_percep_wt_2,// Value of Weight 2 during a previous iteration
    output logic signed [3:0] prev_percep_bias,// Value of Bias during a previous iteration
    output logic signed [3:0] test_percep_present_state,// Present state of the Testing microcode ROM
    output logic signed [3:0] expected_percep_output,// Expected Output from Testing microcode ROM
    output logic signed [3:0] test_percep_output,// Actual Output from Testing microcode ROM
    output logic [3:0] test_percep_result,// Number of correct matches
    output logic [3:0] test_percep_done,// Completion status of Testing
    output logic signed [3:0] test_percep_x1,// Input vector for Testing
    output logic signed [3:0] test_percep_x2,// Input vector for Testing
    output logic [3:0] test_percep_index,// Current position in Testing vectors
);

   logic [15:0] microcode_rom_train [0:5];
   logic [15:0] microcode_rom_test [0:5];
   logic signed [3:0] t1, t2, t3, t4;
   logic signed [3:0] wt1_update, wt2_update, bias_update;
   logic signed [3:0] target;
   logic signed [3:0] prev_wt1_update, prev_wt2_update;
   logic signed [3:0] prev_bias_update;
   logic signed [3:0] prev_wt1_update_test, prev_wt2_update_test;
   logic signed [3:0] prev_bias_update_test;
   logic signed [3:0] t1_update, t2_update, t3_update, t4_update;
   logic [7:0] epoch_counter;
   signed [3:0] stop, prev_percep_wt_1_reg, prev_percep_wt_2_reg, prev_percep_bias_reg, prev_percep_wt_1_update, prev_percep_wt_2_update, prev_percep_bias_update, input_index;
   signed [3:0] percep_wt_1_reg, percep_wt_2_reg, percep_bias_reg, y_in_reg, y_reg, prev_percep_wt_1_update_test, prev_percep_wt_2_update_test, prev_percep_bias_update_test;
   logic [15:0] microinstruction;

   initial begin 
      microinstruction = microcode_rom_train[0];
      next_addr        = 4'd0;
      present_addr     = 4'd0;
      percep_wt_1_reg <= 4'd0;
      percep_wt_2_reg <= 4'd0;
      percep_bias_reg <= 4'd0;
      percep_wt_1_update <= 4'd0;
      percep_wt_2_update <= 4'd0;
      percep_bias_update <= 4'd0;
      y_in_reg <= 4'd0;
      y_reg <= 4'd0;
      input_index <= 2'd0;
   end  

   always@(*) begin
      case (train_action)
         4'd0: begin 
             microinstruction = microcode_rom_train[0];
             next_addr        = microinstruction[15:12];
             train_action     = microinstruction[11:8];
         end
         4'd1 : begin 
             microinstruction = microcode_rom_test[0];
             next_addr        = microcode_rom_test[15:12];
             train_action     = microinstruction[11:8];
         end
   end

   // Testing ROM setup
   microcode_rom_test = {
       0: { present_addr: 4'd5, target: 4'd5, x1: 4'd1, x2: 4'd1, expected_output: 4'd1 },
       1: { present_addr: 4'd5, target: 4'd5, x1: 4'd1, x2: 4'd1, expected_output: 4'd1 },
       2: { present_addr: 4'd5, target: 4'd5, x1: 4'd1, x2: 4'd1, expected_output: 4'd1 },
       3: { present_addr: 4'd5, target: 4'd5, x1: 4'd1, x2: 4'd1, expected_output: 4'd1 }
   };

   // Testing phase control
   always@(*) begin
      case (test_percep_index)
         4'd0 : begin 
             test_percep_present_state <= 4'd0;
             expected_percep_output <= 4'd1;
             test_percep_output <= 4'd1;
             test_percep_result <= 4'd0;
             test_percep_done <= 1'b0;
             test_percep_x1 <= 4'd1;
             test_percep_x2 <= 4'd1;
         end
         4'd4 : begin 
             test_percep_present_state <= 4'd1;
             expected_percep_output <= 4'd1;
             test_percep_output <= 4'd1;
             test_percep_result <= 4'd1;
             test_percep_done <= 1'b0;
             test_percep_x1 <= 4'd1;
             test_percep_x2 <= 4'd1;
         end
         4'd8 : begin 
             test_percep_present_state <= 4'd2;
             expected_percep_output <= 4'd1;
             test_percep_output <= 4'd1;
             test_percep_result <= 4'd2;
             test_percep_done <= 1'b0;
             test_percep_x1 <= 4'd1;
             test_percep_x2 <= 4'd1;
         end
         4'd12 : begin 
             test_percep_present_state <= 4'd3;
             expected_percep_output <= 4'd1;
             test_percep_output <= 4'd1;
             test_percep_result <= 4'd3;
             test_percep_done <= 1'b0;
             test_percep_x1 <= 4'd1;
             test_percep_x2 <= 4'd1;
         end
   end

   // Training phase continues until stop condition met
   always@(*) begin
      case (train_action)
         4'd0 : begin 
             // Training phase continues
             microinstruction = microcode_rom_train[0];
             next_addr        = microcode_rom_train[15:12];
             train_action     = microinstruction[11:8];
         end
         4'd1 : begin 
             // Testing phase starts here
             microinstruction = microcode_rom_test[0];
             next_addr        = microcode_rom_test[15:12];
             train_action     = microinstruction[11:8];
         end
   end

   // Add your rest of the code...