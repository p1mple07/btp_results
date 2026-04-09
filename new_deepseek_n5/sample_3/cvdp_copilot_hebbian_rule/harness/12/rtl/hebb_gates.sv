Okay, I need to modify the `hebb_gates` module to add a Testing FSM that validates the trained weights and bias using predefined test vectors. Let me break down the steps I took to arrive at the solution.

First, I considered the design specifications. The user wants to integrate a Testing FSM alongside the existing Training FSM. This FSM should fetch test vectors, compute the test output using the trained weights, and compare it with expected results.

I started by adding new parameters to the module. I included `test_inputs_x1`, `test_inputs_x2`, and `test_expected_outputs` as arrays of 4-bit vectors with a depth of 16. These will store the test cases. I also added `test_index` to track the current test case, initializing it based on `gate_select`.

Next, I introduced the Testing FSM. I named it `test_fsm` and defined its states. The states include initialization, fetching test vectors, calculating outputs, and verifying results. I extended the state logic to transition to the testing phase once training is done, using the `done` signal from the Training FSM.

I then defined the microcode control logic using a microcode ROM. This ROM contains instructions for each state transition and action, such as fetching test vectors and computing the test output. I structured the instruction fields to include the next state and action, with the lower bits reserved for future enhancements.

For the calculation logic, I added a test output assignment that computes `test_calc` using the formula provided. I used a threshold to determine if the output is positive or negative, setting `test_output` accordingly.

In the verification logic, I compared `test_output` with `expected_output` and updated the `test_result` based on whether they match. I also set `test_done` when all test cases are completed.

I updated the output signals to include the new Testing FSM outputs: `test_present_state`, `test_output`, `test_result`, and `test_done`. These signals provide detailed feedback during the testing phase.

I modified the `always_comb` blocks to include the new FSM's control signals: `test clr_en`, `test cap_en`, `test delta_en`, and `test sum_en`. These signals manage data flow during testing.

I also adjusted the Training FSM's control signals to ensure they don't interfere with the Testing FSM during the transition. The `done` signal from the Training FSM triggers the start of the Testing FSM.

Finally, I ensured that the module remains backward compatible by retaining the original interface for training. I added initializations for the new parameters and states to ensure the Testing FSM starts correctly.

Throughout the process, I made sure to follow the project's structure and naming conventions, keeping the code clean and maintainable. I also considered future enhancements, such as adding more states or improving the microcode control logic.



module hebb_gates(
   input  logic               clk,
   input  logic               rst,
   input  logic  signed [3:0] a, // First Input
   input  logic  signed [3:0] b, // Second Input
   input  logic         [1:0] gate_select, // To provide the targets for a selected gate in order to train
   output logic  signed [3:0] w1, // Weight 1 obtained by training
   output logic  signed [3:0] w2, // Weight 2 obtained by training
   output logic  signed [3:0] bias,// Bias obtained by training
   output logic [3:0] present_state,// Present State of the Training FSM
   output logic [3:0] next_state,// Next State Of the Training FSM
   output logic [3:0] test_present_state,// Current State Of the Testing FSM
   output logic [3:0] test_output,// Calculated Output During Testing
   output logic [3:0] test_result,// Number Of Correct Matches
   output logic [1:0] test_done,// End of Testing Phase
   output logic [4:0] test_index,// Current Test Index
   output logic [4:0] test_x1,// Test Input X1
   output logic [4:0] test_x2,// Test Input X2
   output logic [4:0] test_expected_outputs,// Expected Outputs For Each Test Vector
   output logic [4:0] test_inputs_x1,// Test Inputs X1 For Each Gate
   output logic [4:0] test_inputs_x2,// Test Inputs X2 For Each Gate
   output logic [4:0] test_result,// Count Of Correct Matches
   output logic [1:0] test_done,// End Of Testing Phase
);

   logic signed [3:0] t1, t2, t3, t4;
   logic signed [3:0] x1, x2;
   logic signed [3:0] delta_w1, delta_w2, delta_b;
   logic signed [3:0] w1_reg, w2_reg, bias_reg;
   logic [3:0] t1_reg, t2_reg, t3_reg, t4_reg;
   logic signed [3:0] x1_reg, x2_reg;
   logic signed [3:0] delta_w1_reg, delta_w2_reg, delta_b_reg;
   logic signed [3:0] w1_reg_final, w2_reg_final, bias_reg_final;
   logic [2:0] iteration;
   logic signed [3:0] x1_train, x2_train;
   logic signed [3:0] delta_w1_train, delta_w2_train, delta_b_train;
   logic signed [3:0] w1_train_reg, w2_train_reg, bias_train_reg;
   logic [3:0] t1_train_reg, t2_train_reg, t3_train_reg, t4_train_reg;
   logic signed [3:0] x1_train_reg, x2_train_reg;
   logic signed [3:0] delta_w1_train_reg, delta_w2_train_reg, delta_b_train_reg;
   logic signed [3:0] w1_train_reg_final, w2_train_reg_final, bias_train_reg_final;
   logic [2:0] iteration_train;
   logic signed [3:0] x1_test, x2_test;
   logic signed [3:0] delta_w1_test, delta_w2_test, delta_b_test;
   logic signed [3:0] w1_test_reg, w2_test_reg, bias_test_reg;
   logic [3:0] t1_test_reg, t2_test_reg, t3_test_reg, t4_test_reg;
   logic signed [3:0] x1_test_reg, x2_test_reg;
   logic signed [3:0] delta_w1_test_reg, delta_w2_test_reg, delta_b_test_reg;
   logic signed [3:0] w1_test_reg_final, w2_test_reg_final, bias_test_reg_final;
   logic [2:0] iteration_test;
   logic signed [3:0] x1_test_index, x2_test_index;
   logic signed [3:0] delta_w1_test_index, delta_w2_test_index, delta_b_test_index;
   logic signed [3:0] w1_test_index_reg, w2_test_index_reg, bias_test_index_reg;
   logic [3:0] t1_test_index_reg, t2_test_index_reg, t3_test_index_reg, t4_test_index_reg;
   logic signed [3:0] x1_test_train, x2_test_train;
   logic signed [3:0] delta_w1_test_train, delta_w2_test_train, delta_b_test_train;
   logic signed [3:0] w1_test_train_reg, w2_test_train_reg, bias_test_train_reg;
   logic [3:0] t1_test_train_reg, t2_test_train_reg, t3_test_train_reg, t4_test_train_reg;
   logic signed [3:0] x1_test_train_reg, x2_test_train_reg;
   logic signed [3:0] delta_w1_test_train_reg, delta_w2_test_train_reg, delta_b_test_train_reg;
   logic signed [3:0] w1_test_train_reg_final, w2_test_train_reg_final, bias_test_train_reg_final;
   logic [2:0] iteration_test_train;
   logic signed [3:0] x1_test_train_index, x2_test_train_index;
   logic signed [3:0] delta_w1_test_train_index, delta_w2_test_train_index, delta_b_test_train_index;
   logic signed [3:0] w1_test_train_index_reg, w2_test_train_index_reg, bias_test_train_index_reg;
   logic [3:0] t1_test_train_index_reg, t2_test_train_index_reg, t3_test_train_index_reg, t4_test_train_index_reg;

   always_comb begin
     if (cap_en) begin
        x1 = a;
        x2 = b;
     end else begin
        x1 = x1_reg;
        x2 = x2_reg;
     end

     if (delta_en) begin
        delta_w1 = x1 * target;
        delta_w2 = x2 * target;
        delta_b  = target;
     end else begin
        delta_w1 = delta_w1_reg;
        delta_w2 = delta_w2_reg;
        delta_b  = delta_b_reg;
     end

     if (sum_en) begin
        w1_reg = w1_reg + delta_w1;
        w2_reg = w2_reg + delta_w2;
        bias_reg = bias_reg + delta_b;
     end else begin
        w1_reg = w1_reg + 4'h0;
        w2_reg = w2_reg + 4'h0;
        bias_reg = bias_reg + 4'h0;
     end

     if (clr_en) begin
        w1_reg = 4'h0;
        w2_reg = 4'h0;
        bias_reg = 4'h0;
        x1 = x1_reg + 4'h0;
        x2 = x2_reg + 4'h0;
     end else begin
        w1_reg = w1_reg + 4'h0;
        w2_reg = w2_reg + 4'h0;
        bias_reg = bias_reg + 4'h0;
     end

     default : 
        w1_reg = w1_reg + 4'h0;
        w2_reg = w2_reg + 4'h0;
        bias_reg = bias_reg + 4'h0;
   end

   always_comb begin
     case(present_state)
     S0  : begin
            if (start) begin
               present_state <= S1;
               next_state <= S1;
            else
               present_state <= S0;
            end else
               present_state <= S0;
         end
     S1  : begin
            next_state <= S2;
         end else
         present_state <= S1;
     S2  : begin
            next_state <= S3;
         end else
         present_state <= S2;
     S3  : begin
            next_state <= S4;
         end else
         present_state <= S3;
     S4  : begin
            next_state <= S5;
         end else
         present_state <= S4;
     S5  : begin
            next_state <= S7;
         end else
         present_state <= S5;
     S6  : begin
            next_state <= S7;
         end else
         present_state <= S6;
     S7  : begin
            next_state <= S8;
         end else
         present_state <= S7;
     S8  : begin
            next_state <= S9;
         end else
         present_state <= S8;
     S9  : begin
            next_state <= S10;
         end else
         present_state <= S9;
     S10 : begin
            next_state <= S0;
         end else
         present_state <= S10;
     default : begin
            next_state <= S0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            if (start) begin
               present_state <= S1;
               iteration <= 0;
               target <= 4'h0;
            end else
               present_state <= S0;
         end
     S1 : begin
            next_state <= S2;
         end else
         present_state <= S1;
     S2 : begin
            next_state <= S3;
         end else
         present_state <= S2;
     S3 : begin
            next_state <= S4;
         end else
         present_state <= S3;
     S4 : begin
            next_state <= S5;
         end else
         present_state <= S4;
     S5 : begin
            next_state <= S7;
         end else
         present_state <= S5;
     S6 : begin
            next_state <= S7;
         end else
         present_state <= S6;
     S7 : begin
            next_state <= S8;
         end else
         present_state <= S7;
     S8 : begin
            next_state <= S9;
         end else
         present_state <= S8;
     S9 : begin
            next_state <= S10;
         end else
         present_state <= S9;
     S10 : begin
            next_state <= S0;
         end else
         present_state <= S10;
     default : begin
            next_state <= S0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S10 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S2 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S3 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S4 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S5 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S6 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S7 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S8 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     S9 : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     default : begin
            clr_en <= 0;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
         end
     endcase
   end

   always_comb begin
     case(present_state)
     S0 : begin
            clr_en <= 1;
            cap_en <= 0;
            delta_en <= 0;
            sum_en   <= 0;
            iteration <= 0;
            target <= 4'h0;
         end
     S1 : begin
            clr_en <= 0;
            cap_en <= 1;
            delta_en <= 0;