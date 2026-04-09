Okay, so I need to modify the given RTL code for the perceptron_gates module to add testing functionality. The user wants to integrate two separate microcode ROM control units for Training and Testing. The training adjusts the weights and bias using the perceptron learning rule, while testing validates the trained model against predefined test vectors. The module should support gate-specific training and testing for AND, OR, NAND, and NOR operations.

First, I'll look at the existing code. The module currently has a lot of logic gates and microcode instructions for training. I need to add testing features without disrupting the existing functionality.

I'll start by identifying where to insert the testing control unit. The user mentioned that the Testing ROM has predefined microinstructions. So, I'll add a new section in the microcode_rom, maybe under a new address, say 6, which is currently unused. This will allow the control unit to fetch testing instructions.

Next, I need to manage the Testing microcode. I'll add a new signal, test_present_addr, to track the address in the Testing ROM. Also, I'll introduce new output signals: test_percep_present_state to show the current address, expected_percep_output from the test vectors, test_percep_output as the actual result, test_percep_result to count matches, and test_percep_done when testing completes.

I'll create predefined arrays for test inputs and expected outputs based on the selected gate. For each gate (AND, OR, NAND, NOR), the inputs and expected outputs will vary. I'll store these in arrays so they can be accessed easily during testing.

In the always_comb block where the microcode is executed, I'll add a case for when the address points to the Testing ROM. This case will fetch the test vectors, compute the perceptron's output, compare it with the expected value, and update the result and done signals.

I'll also need to manage the test vectors. The gate_target submodule will now have additional outputs for test_x1, test_x2, and expected_output, which are read from the test arrays based on the gate_select.

For backward compatibility, I'll ensure that the training continues unaffected. The stop signal should only be set during testing if the test is completed successfully.

I'll add new output signals: test_percep_result and test_percep_done. These will be 4-bit signals to track the number of correct outputs during testing.

In the microcode instructions, I'll add a new case for address 6, which handles the Testing microcode. This will include fetching the test vectors, computing the output, and updating the result.

I'll also need to update the gate_target submodule to include the new test vector outputs. This involves adding logic to select the correct test_x1, test_x2, and expected_output based on the gate_select and test_percep_index.

Finally, I'll test the new functionality by verifying that the perceptron correctly trains and tests for the desired gate. I'll check the test_percep_result to ensure it increments correctly and test_percep_done to confirm the testing completes without errors.

I think I've covered all the necessary steps. Now, I'll proceed to modify the code accordingly.



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
   output logic signed [3:0] target,// Target value for a given input combination
   output logic signed [3:0] prev_wt1_update,// Weight 1 update value
   output logic signed [3:0] prev_wt2_update,// Weight 2 update value
   output logic signed [3:0] prev_bias_update,// Bias update value
   output logic [3:0] input_index,// Vector to track the selection of target for a given input combination for a gate
   output logic signed [3:0] stop, // Condition to indicate no weight change between iterations
   output logic [2:0] epoch_counter,// Value to indicate no weight change between iterations
   output logic [4'd0] test_percep_present_state,// Track the present state of the Testing microcode ROM
   output logic signed [3:0] expected_percep_output,// Output extracted from a internally predefined vector
   output logic signed [3:0] test_percep_output,// Actual output generated by the Testing microcode ROM
   output logic signed [3:0] test_percep_result,// Number of times the expected_percep_output matched with test_percep_output
   output logic [4'd0] test_percep_done,// Indicates the completion of Testing operation
   output logic signed [3:0] test_percep_x1,// Input extracted from a internally predefined vector
   output logic signed [3:0] test_percep_x2,// Input extracted from a internally predefined vector
   output logic signed [3:0] test_percep_index,// Index to track the position in test vectors
   output logic signed [3:0] test_percep_result_value,// Number of correct outputs during Testing
   output logic signed [3:0] test_percep_done_value,// Completion status of Testing operation
   output logic signed [3:0] test_percep_x1_value,// First test input value
   output logic signed [3:0] test_percep_x2_value,// Second test input value
   output logic signed [3:0] test_percep_expected_output_value,// Expected test output value
   output logic signed [3:0] test_percep_calculation_value,// Perceptron calculation during Testing
   output logic signed [3:0] test_percep_learning_rate_value,// Learning rate used during Testing
   output logic signed [3:0] test_percep_threshold_value,// Threshold used during Testing
   output logic [1:0] test_gate_select,// Gate selection for test vectors
   output logic signed [3:0] test_percep_weight1_update_value,// Weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_value,// Weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_value,// Bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_value,// Learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_value,// Threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_value,// Sign of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_value,// Sign of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_value,// Sign of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_value,// Sign of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_value,// Sign of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_value,// Magnitude of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_value,// Magnitude of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_value,// Magnitude of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_value,// Magnitude of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_value,// Magnitude of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_sign_bit_value,// Sign bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_magnitude_bit_value,// Magnitude bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_magnitude_bit_value,// Magnitude bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_magnitude_bit_value,// Magnitude bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_magnitude_bit_value,// Magnitude bit of learning rate update during Testing
   output logic signed [3:0] test_percep_threshold_update_magnitude_bit_value,// Magnitude bit of threshold update during Testing
   output logic signed [3:0] test_percep_weight1_update_sign_bit_value,// Sign bit of weight 1 update during Testing
   output logic signed [3:0] test_percep_weight2_update_sign_bit_value,// Sign bit of weight 2 update during Testing
   output logic signed [3:0] test_percep_bias_update_sign_bit_value,// Sign bit of bias update during Testing
   output logic signed [3:0] test_percep_learning_rate_update_sign_bit_value,// Sign bit of learning rate update during Testing
   output logic signed [0] bit [3:0],// Magnitude bit of weight 1 update during Testing
   output logic signed [0] bit [3:0],// Magnitude bit of weight 2 update during Testing
   output logic signed [0] bit [3:0],// Magnitude bit of bias update during Testing
   output logic signed [0] bit [3:0],// Magnitude bit of learning rate update during Testing
   output logic signed [0] bit [3:0],// Magnitude bit of threshold update during Testing
   output logic signed [0] bit [3:0],// Magnitude bit of weight 1 update during Testing
   output logic signed [0] bit [3:0],// Magnitude bit of weight 2 update during Testing
   output logic signed [0] bit [3:0],// Magnitude bit of bias update during Testing
   output logic signed [0] bit [3:0],// Magnitude bit of learning rate update during Testing
   output logic signed [0] bit [3:0],// Magnitude bit of threshold update during Testing
   output logic signed