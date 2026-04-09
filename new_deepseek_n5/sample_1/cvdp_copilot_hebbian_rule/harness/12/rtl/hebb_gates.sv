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
   output logic [3:0] test_present_state,// Present State Of the Testing FSM
   output logic [3:0] test_output,// Output Of the Testing FSM
   output logic [3:0] test_result,// Number Of Correct Matches
   output logic 1              test_done,// Signal indicating completion of testing
   output logic [3:0] test_index,// Current Index Of Test Vector
   output logic [3:0] test_result,// Count Of Correct Matches
   output logic [3:0] test_done,// Signal indicating completion of testing
);

   logic signed [3:0] t1, t2, t3, t4;
   logic signed [3:0] x1, x2;
   logic signed [3:0] delta_w1, delta_w2, delta_b;
   logic signed [3:0] w1_reg, w2_reg, bias_reg;
   logic signed [3:0] x1_reg, x2_reg;
   logic signed [3:0] delta_w1_reg, delta_w2_reg, delta_b_reg;
   logic signed [3:0] w1_reg, w2_reg, bias_reg;
   logic [2:0] iteration;
   logic signed [3:0] x1, x2;
   logic signed [3:0] delta_w1, delta_w2, delta_b;
   logic signed [3:0] w1_reg, w2_reg, bias_reg;
   logic signed [3:0] x1_reg, x2_reg;
   logic signed [3:0] delta_w1_reg, delta_w2_reg, delta_b_reg;
   logic signed [3:0] w1_reg, w2_reg, bias_reg;
   logic [2:0] iteration;
   logic signed [3:0] x1, x2;
   logic signed [3:0] delta_w1, delta_w2, delta_b;
   logic signed [3:0] w1_reg, w2_reg, bias_reg;
   logic signed [3:0] x1_reg, x2_reg;
   logic signed [3:0] delta_w1_reg, delta_w2_reg, delta_b_reg;
   logic signed [3:0] w1_reg, w2_reg, bias_reg;

   always_comb begin
     if(cap_en) begin
        x1 = a;
        x2 = b;
     end else begin
        x1 = x1 + 4'h0;
        x2 = x2 + 4'h0;
     end
   
     if(delta_en) begin
        delta_w1 = x1 * target;
        delta_w2 = x2 * target;
        delta_b  = target;
     end else begin
        delta_w1 = delta_w1 + 4'h0;
        delta_w2 = delta_w2 + 4'h0;
        delta_b  = delta_b + 4'h0; 
     end
   
     if(sum_en) begin
        w1_reg = w1_reg + delta_w1;
        w2_reg = w2_reg + delta_w2;
        bias_reg = bias_reg + delta_b;
     end else begin
        w1_reg = w1_reg + 4'h0;
        w2_reg = w2_reg + 4'h0;
        bias_reg = bias_reg + 4'h0;
     end
   
     if(clr_en) begin
        w1_reg = 0;
        w2_reg = 0;
        bias_reg = 0;
     end else begin
        w1_reg = w1_reg + 4'h0;
        w2_reg = w2_reg + 4'h0;
        bias_reg = bias_reg + 4'h0; 
     end
   
     always_ff @(posedge clk or negedge rst) begin
         if(!rst) begin
             present_state <= S0;
             iteration <= 0;
         end else
             present_state <= next_state;
     end
   
     always_comb begin
         case(present_state)
             S0  : begin 
                if(start) begin
                    next_state = S1;
                end else begin
                    next_state = S0;
                end
             end 
             S1  : begin 
                next_state = S2;
             end
             S2  : begin 
                if(iteration == 0) begin
                    next_state = S3;
                else if(iteration == 1) begin
                    next_state = S4;
                else if(iteration == 2) begin
                    next_state = S5;
                else 
                    next_state = S6;
                end
             end
             S3  : begin 
                next_state = S7;
               
             end
             S4  : begin 
                next_state = S7;
               
             end
             S5  : begin 
                next_state = S7;
               
             end
             S6  : begin 
                next_state = S7;
               
             end
             S7  :begin
                next_state = S8;
             end
             S8  :begin
                next_state = S9;
             end
             S9  :begin
                next_state = S10;
             end
             S10 : begin
                next_state = S10;
             end
             default : begin
                next_state = S0;
             end
         endcase
     end
   
     always_comb begin
         case(present_state)
             S0 : begin
                clr_en = 1;
                cap_en = 0;
                delta_en = 0;
                sum_en = 0;
                iteration = 0;
                target = target + 4'h0;
              end 
             S1 : begin
                clr_en = 0;
                cap_en = 1;
                delta_en = 0;
                sum_en = 0;  
                iteration = iteration + 0;  
                target = target + 4'h0;              
              end
             S2 : begin
                clr_en = 0;
                cap_en = 0;
                delta_en = 0;
                sum_en = 0; 
                iteration = iteration + 0;     
                target = target + 4'h0;              
              end
             S3 : begin
                clr_en = 0;
                cap_en = 0;
                delta_en = 0;
                sum_en = 0;
                iteration = iteration + 0;
                target = t1;
              end
             S4 : begin
                clr_en = 0;
                cap_en = 0;
                delta_en = 0;
                sum_en = 0;
                iteration = iteration + 0;
                target = t2;
              end     
             S5 : begin
                clr_en = 0;
                cap_en = 0;
                delta_en = 0;
                sum_en = 0;
                iteration = iteration + 0;
                target = t3;
              end  
             S6 : begin
                clr_en = 0;
                cap_en = 0;
                delta_en = 0;
                sum_en = 0;
                iteration = iteration + 0;
                target = t4;
              end        
             S7 :begin
                clr_en = 0;
                cap_en = 0;
                delta_en = 1;
                sum_en = 0;
                iteration = iteration + 0;
                target = target + 4'h0;
              end
             S8 :begin
                clr_en = 0;
                cap_en = 0;
                delta_en = 0;
                sum_en = 1;
                iteration = iteration + 1;
                target = target + 4'h0;
              end
             S9 :begin
                clr_en = 0;
                cap_en = 0;
                delta_en = 0;
                sum_en = 0;
                iteration = iteration + 0;
                target = target + 4'h0;
              end  
             S10 :begin
                clr_en = 0;
                cap_en = 0;
                delta_en = 0;
                sum_en = 0;
                iteration = 0;
                target = 4'h0;
              end
             default : begin
                clr_en = 0;
                cap_en = 0;
                delta_en = 0;
                sum_en = 0;
                iteration = 0;
                target = 4'h0;
             end
         endcase
     end
   
     // Testing FSM
     logic [3:0] test_index, test_result, test_done;
     register [3:0] test_present_state;
     register [3:0] test_output;
     register [3:0] test_result;
     register 1              test_done;
     register [3:0] test_index;
   
     // Test vectors
     parameter [15:0] test_inputs_x1 = 4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9, 4'd10, 4'd11, 4'd12, 4'd13, 4'd14, 4'd15;
     parameter [15:0] test_inputs_x2 = 4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9, 4'd10, 4'd11, 4'd12, 4'd13, 4'd14, 4'd15;
     parameter [15:0] test_expected_outputs = 4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9, 4'd10, 4'd11, 4'd12, 4'd13, 4'd14, 4'd15;
   
     always_comb begin
         case(present_state)
             S10 : begin
                // Initialize Testing FSM
                test_index <= 4'b0000;
                test_result <= 4'h0;
                test_done <= 1'b0;
                test_present_state <= S0;
                // Fetch first test vector based on gate_select
                test_index <= test_index + 4'h1;
                test_x1 <= test_inputs_x1[test_index];
                test_x2 <= test_inputs_x2[test_index];
                test_target <= test_expected_outputs[test_index];
                test_calc <= test_x1 * w1 + test_x2 * w2 + bias;
                test_output <= (test_calc > 0) ? 4'd1 : 4'd1;
                if(test_output == test_target) begin
                    test_result <= test_result + 4'h1;
                end else begin
                    test_result <= 4'h0;
                end
                test_done <= 1'b0;
                next_state <= S1;
             end
             S1 : begin
                // Process next test vector
                test_index <= test_index + 4'h1;
                test_x1 <= test_inputs_x1[test_index];
                test_x2 <= test_inputs_x2[test_index];
                test_target <= test_expected_outputs[test_index];
                test_calc <= test_x1 * w1 + test_x2 * w2 + bias;
                test_output <= (test_calc > 0) ? 4'd1 : 4'd1;
                if(test_output == test_target) begin
                    test_result <= test_result + 4'h1;
                end else begin
                    test_result <= 4'h0;
                end
                test_done <= 1'b0;
                next_state <= S2;
             end
             S2 : begin
                // Process next test vector
                test_index <= test_index + 4'h1;
                test_x1 <= test_inputs_x1[test_index];
                test_x2 <= test_inputs_x2[test_index];
                test_target <= test_expected_outputs[test_index];
                test_calc <= test_x1 * w1 + test_x2 * w2 + bias;
                test_output <= (test_calc > 0) ? 4'd1 : 4'd1;
                if(test_output == test_target) begin
                    test_result <= test_result + 4'h1;
                end else begin
                    test_result <= 4'h0;
                end
                test_done <= 1'b0;
                next_state <= S3;
             end
             S3 : begin
                // Process next test vector
                test_index <= test_index + 4'h1;
                test_x1 <= test_inputs_x1[test_index];
                test_x2 <= test_inputs_x2[test_index];
                test_target <= test_expected_outputs[test_index];
                test_calc <= test_x1 * w1 + test_x2 * w2 + bias;
                test_output <= (test_calc > 0) ? 4'd1 : 4'd1;
                if(test_output == test_target) begin
                    test_result <= test_result + 4'h1;
                end else begin
                    test_result <= 4'h0;
                end
                test_done <= 1'b0;
                next_state <= S4;
             end
             S4 : begin
                // Process next test vector
                test_index <= test_index + 4'h1;
                test_x1 <= test_inputs_x1[test_index];
                test_x2 <= test_inputs_x2[test_index];
                test_target <= test_expected_outputs[test_index];
                test_calc <= test_x1 * w1 + test_x2 * w2 + bias;
                test_output <= (test_calc > 0) ? 4'd1 : 4'd1;
                if(test_output == test_target) begin
                    test_result <= test_result + 4'h1;
                end else begin
                    test_result <= 4'h0;
                end
                test_done <= 1'b0;
                next_state <= S5;
             end
             S5 : begin
                // Process next test vector
                test_index <= test_index + 4'h1;
                test_x1 <= test_inputs_x1[test_index];
                test_x2 <= test_inputs_x2[test_index];
                test_target <= test_expected_outputs[test_index];
                test_calc <= test_x1 * w1 + test_x2 * w2 + bias;
                test_output <= (test_calc > 0) ? 4'd1 : 4'd1;
                if(test_output == test_target) begin
                    test_result <= test_result + 4'h1;
                end else begin
                    test_result <= 4'h0;
                end
                test_done <= 1'b0;
                next_state <= S6;
             end
             S6 : begin
                // Process next test vector
                test_index <= test_index + 4'h1;
                test_x1 <= test_inputs_x1[test_index];
                test_x2 <= test_inputs_x2[test_index];
                test_target <= test_expected_outputs[test_index];
                test_calc <= test_x1 * w1 + test_x2 * w2 + bias;
                test_output <= (test_calc > 0) ? 4'd1 : 4'd1;
                if(test_output == test_target) begin
                    test_result <= test_result + 4'h1;
                end else begin
                    test_result <= 4'h0;
                end
                test_done <= 1'b0;
                next_state <= S7;
             end
             S7 : begin
                // Process next test vector
                test_index <= test_index + 4'h1;
                test_x1 <= test_inputs_x1[test_index];
                test_x2 <= test_inputs_x2[test_index];
                test_target <= test_expected_outputs[test_index];
                test_calc <= test_x1 * w1 + test_x2 * w2 + bias;
                test_output <= (test_calc > 0) ? 4'd1 : 4'd1;
                if(test_output == test_target) begin
                    test_result <= test_result + 4'h1;
                end else begin
                    test_result <= 4'h0;
                end
                test_done <= 1'b0;
                next_state <= S8;
             end
             S8 : begin
                // Process next test vector
                test_index <= test_index + 4'h1;
                test_x1 <= test_inputs_x1[test_index];
                test_x2 <= test_inputs_x2[test_index];
                test_target <= test_expected_outputs[test_index];
                test_calc <= test_x1 * w1 + test_x2 * w2 + bias;
                test_output <= (test_calc > 0) ? 4'd1 : 4'd1;
                if(test_output == test_target) begin
                    test_result <= test_result + 4'h1;
                end else begin
                    test_result <= 4'h0;
                end
                test_done <= 1'b0;
                next_state <= S9;
             end
             S9 : begin
                // Process next test vector
                test_index <= test_index + 4'h1;
                test_x1 <= test_inputs_x1[test_index];
                test_x2 <= test_inputs_x2[test_index];
                test_target <= test_expected_outputs[test_index];
                test_calc <= test_x1 * w1 + test_x2 * w2 + bias;
                test_output <= (test_calc > 0) ? 4'd1 : 4'd1;
                if(test_output == test_target) begin
                    test_result <= test_result + 4'h1;
                end else begin
                    test_result <= 4'h0;
                end
                test_done <= 1'b0;
                next_state <= S10;
             end
             S10 : begin
                // Testing complete
                next_state <= S0;
                test_done <= 1'b1;
             end
         endcase
     end
     assign w1_reg = w1;
     assign w2_reg = w2;
     assign bias_reg = bias;
     assign present_state = present_state;
     assign next_state = next_state;
     assign test_present_state = test_present_state;
     assign test_output = test_output;
     assign test_result = test_result;
     assign test_done = test_done;
     assign test_index = test_index;
     assign test_x1 = test_x1;
     assign test_x2 = test_x2;
     assign test_target = test_target;
     assign test_calc = test_calc;
     assign test_output = test_output;
     assign test_result = test_result;
     assign test_done = test_done;
     assign test_present_state = test_present_state;
   endmodule