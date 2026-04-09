module hebb_gates(
   input  logic               clk,
   input  logic               rst,
   input  logic               start, // To start the FSM
   input  logic  signed [3:0] a, // First Input
   input  logic  signed [3:0] b, // Second Input
   input  logic         [1:0] gate_select, // To provide the targets for a selected gate in order to train
   output logic  signed [3:0] w1, // Weight 1 obtained by training
   output logic  signed [3:0] w2, // Weight 2 obtained by training
   output logic  signed [3:0] bias,// Bias obtained by training
   output logic [3:0] present_state,// Present State of the Training FSM
   output logic [3:0] next_state // Next_State of the Training FSM
   
   output logic [3:0] test_present_state, // Present State of the Testing FSM
   output logic [3:0] test_output, // Calculated output during testing
   output logic [3:0] test_result, // Count of correct matches
   output logic done // Indicates the end of the testing phase
   
   // Testing FSM related inputs
   input  logic  [15:0] test_index,
   input  logic  [3:0] test_x1,
   input  logic  [3:0] test_x2,
   input  logic  [3:0] test_expected_output
   
   // Testing FSM related outputs
   output logic test_done
   
   // Control signals
   logic signed [3:0] t1;
   logic signed [3:0] t2;
   logic signed [3:0] t3;
   logic signed [3:0] t4;
   
   gate_target dut(
       .gate_select(gate_select),
       .o_1        (t1),
       .o_2        (t2),
       .o_3        (t3),
       .o_4        (t4)
   );
   
   localparam [3:0] S0 = 4'd0;
   localparam [3:0] S1 = 4'd1;
   localparam [3:0] S2 = 4'd2;
   localparam [3:0] S3 = 4'd3;
   localparam [3:0] S4 = 4'd4;
   localparam [3:0] S5 = 4'd5;
   localparam [3:0] S6 = 4'd6;
   localparam [3:0] S7 = 4'd7;
   localparam [3:0] S8 = 4'd8;
   localparam [3:0] S9 = 4'd9;
   localparam [3:0] S10 = 4'd10;
   localparam [3:0] TEST_S0 = 4'd11;
   localparam [3:0] TEST_S1 = 4'd12;
   
   logic signed [3:0] x1;
   logic signed [3:0] x2;
   logic signed [3:0] delta_w1;
   logic signed [3:0] delta_w2;
   logic signed [3:0] delta_b;
   logic signed [3:0] w1_reg;
   logic signed [3:0] w2_reg;
   logic signed [3:0] bias_reg;
   logic signed [15:0] test_index;
   logic signed [3:0] test_x1;
   logic signed [3:0] test_x2;
   logic signed [3:0] test_expected_output;
   logic signed [3:0] test_output;
   logic signed [3:0] test_result;
   logic test_done;
   logic delta_en;
   logic sum_en;
   logic clr_en;
   logic cap_en;
  
   always_comb begin
     if(cap_en ) begin
        x1 = a;
        x2 = b;
     end else begin
        x1 = x1 + 4'h0;
        x2 = x2 + 4'h0;
     end
   
   end
   
   always_comb begin
     
     if(delta_en) begin
       delta_w1 = x1 * target;
       delta_w2 = x2 * target;
       delta_b  = target;
     end else begin
       delta_w1 = delta_w1 + 4'h0;
       delta_w2 = delta_w2 + 4'h0;
       delta_b  = delta_b + 4'h0; 
     end
   
  end
   
  always_comb begin
     
     if(sum_en) begin
       w1_reg = w1_reg + delta_w1;
       w2_reg = w2_reg + delta_w2;
       bias_reg = bias_reg + delta_b;
     end else begin
       w1_reg = w1_reg + 4'h0;
       w2_reg = w2_reg + 4'h0;
       bias_reg = bias_reg + 4'h0;
   end
  end
   
   always_comb begin
     
     if(clr_en) begin
       w1_reg = 0;
       w2_reg = 0;
       bias_reg = 0;
     end else begin
       w1_reg = w1_reg + 4'h0;
       w2_reg = w2_reg + 4'h0;
       bias_reg = bias_reg + 4'h0; 
    end
   end
   
   always_ff@(posedge clk or negedge rst) begin
       if(!rst) begin
          present_state <= S0;
          iteration <= 0;
          test_done <= 1'b0;
        end else
          present_state <= next_state;
          test_done <= 1'b0;
   end

   always_comb begin
        next_state = present_state;
        
     case(present_state)
             S0 : begin 
                      if(start)
                         next_state = S1;
                      else
                         next_state = S0;
                   end
             S1 : begin 
                         next_state = S2;
                   end
             S2 : begin 
                         next_state = S3;
                   end
             S3 : begin 
                         next_state = S4;
                   end
             S4 : begin 
                         next_state = S7;
                   end
             S5 : begin 
                         next_state = S7;
                  end
             S6 : begin 
                         next_state = S7;
                  end
             S7 : begin
                         next_state = TEST_S0;
                  end
             S8 : begin
                         next_state = TEST_S1;
                  end
             S9 : begin
                      if(iteration < 4)
                         next_state = S1;
                      else
                         next_state = S10;
                   end
             S10 : begin
                      next_state = S0;
                   end
             TEST_S0 : begin
                         if(test_index == 4'b0000)
                            test_present_state <= S0;
                         else if(test_index == 4'b0001)
                            test_present_state <= S1;
                         else if(test_index == 4'b0010)
                            test_present_state <= S2;
                         else if(test_index == 4'b0011)
                            test_present_state <= S3;
                         else if(test_index == 4'b0100)
                            test_present_state <= S4;
                         else if(test_index == 4'b0101)
                            test_present_state <= S5;
                         else if(test_index == 4'b0110)
                            test_present_state <= S6;
                         else if(test_index == 4'b0111)
                            test_present_state <= S7;
                      end
             TEST_S1 : begin
                         if(test_index == 4'b1000)
                            test_present_state <= S8;
                         else if(test_index == 4'b1001)
                            test_present_state <= S9;
                         else if(test_index == 4'b1010)
                            test_present_state <= S10;
                         else if(test_index == 4'b1011)
                            test_present_state <= S0;
                      end
             default : begin
                      test_present_state <= S0;
                      test_done <= 1'b0;
                   end
        endcase
   end
   
   always_comb begin
        
      case(present_state)
             S0 : begin
                    clr_en = 1;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en   = 0;
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
             S7 : begin
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 1;
                    sum_en = 0;
                    iteration = iteration + 0;
                    target = target + 4'h0;
                  end
             TEST_S0 : begin
                         test_output <= (w1 * test_x1) + (w2 * test_x2) + bias;
                         test_result <= (test_output == test_expected_output) ? 4'b1 : 4'b0;
                         test_done <= (test_index == 15'b1111) ? 1'b1 : 1'b0;
                      end
             TEST_S1 : begin
                         test_output <= (w1 * test_x1) + (w2 * test_x2) + bias;
                         test_result <= (test_output == test_expected_output) ? 4'b1 : 4'b0;
                         test_done <= (test_index == 15'b1111) ? 1'b1 : 1'b0;
                      end
             
             default : begin
                      clr_en = 0;
                      cap_en = 0;
                      delta_en = 0;
                      sum_en = 0;
                      iteration = 0;
                      target = target + 4'h0;
                     end
       endcase
   end
   assign w1 = w1_reg;
   assign w2 = w2_reg;
   assign bias = bias_reg;
   assign test_present_state = test_present_state;
   assign test_output = test_output;
   assign test_done = test_done;
endmodule
