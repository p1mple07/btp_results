module hebb_gates(
   input  logic  clk,
   input  logic rst,
   input  logic start, // To start the FSM
   input  logic  a, // First Input
   input  logic  b, // Second Input
   input  logic  gate_select, // To provide the targets for a selected gate in order to train
   output logic  w1, // Weight 1 obtained by training
   output logic  w2, // Weight 2 obtained by training
   output logic  bias,// Bias obtained by training
   output logic  present_state,// Present State of the Training FSM
   output logic  next_state // Next State of the Training FSM
);

   // Add Testing FSM related variables
   logic  test_present_state; // State of the Testing FSM
   logic  test_index; // Current index for test vectors
   logic  test_result; // Number of correct test results
   logic  test_done; // Whether testing is complete
   logic  test_output; // Output from the Testing FSM

   // Define test vectors
   logic [3:0] test_inputs_x1 = 4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9, 4'd10, 4'd11, 4'd12, 4'd13, 4'd14, 4'd15;
   logic [3:0] test_inputs_x2 = 4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9, 4'd10, 4'd11, 4'd12, 4'd13, 4'd14, 4'd15;
   logic [3:0] test_expected_outputs = 4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9, 4'd10, 4'd11, 4'd12, 4'd13, 4'd14, 4'd15;

   // Add Testing FSM
   always_comb begin
      case(test_present_state)
         S0 : begin
             test_index = 4'd0;
             test_result = 4'd0;
             test_done = 1'b0;
         end
         S1 : begin
             test_index = 4'd4;
             test_result = 4'd0;
             test_done = 1'b0;
         end
         S2 : begin
             test_index = 4'd8;
             test_result = 4'd0;
             test_done = 1'b0;
         end
         S3 : begin
             test_index = 4'd12;
             test_result = 4'd0;
             test_done = 1'b0;
         end
         S4 : begin
             test_index = 4'd16;
             test_result = 4'd0;
             test_done = 1'b0;
         end
         default : begin
             test_index = 4'd0;
             test_result = 4'd0;
             test_done = 1'b0;
         endcase
   endcase

   // Add microcode ROM for Testing FSM
   always_comb begin
      case(test_present_state)
         S0 : begin
             output = 4'd0;
         end
         S1 : begin
             output = 4'd0;
         end
         S2 : begin
             output = 4'd0;
         end
         S3 : begin
             output = 4'd0;
         end
         S4 : begin
             output = 4'd0;
         end
         default : begin
             output = 4'd0;
         endcase
   endcase

   // Add test logic
   always_comb begin
      case(test_present_state)
         S0: begin
             if(test_index < 16) begin
                 test_x1 = test_inputs_x1[test_index];
                 test_x2 = test_inputs_x2[test_index];
                 test_target = test_expected_outputs[test_index];
                 test_calc = (w1 * test_x1) + (w2 * test_x2) + bias;
                 test_output = 4'd1 if (test_calc > 0) else 4'd0;
                 test_result = test_result + (test_output == test_target ? 4'd1 : 4'd0);
                 test_index = test_index + 1;
             end
             else begin
                 test_done = 1'b1;
             end
         end
         S1 : begin
             test_done = 1'b0;
         end
         S2 : begin
             test_done = 1'b0;
         end
         S3 : begin
             test_done = 1'b0;
         end
         S4 : begin
             test_done = 1'b0;
         end
         default : begin
             test_done = 1'b0;
         endcase
   endcase

   // Add output line for test results
   output logic test_output;

   // Add control signals for Testing FSM
   input  test_clr_en;
   input  test_cap_en;
   input  test_delta_en;
   input  test_sum_en;

   // Add output line to Training FSM
   output logic test_output;

   // Add FSM to Training FSM
   always_comb begin
      if(test_done) begin
          present_state <= S0;
      end
   end