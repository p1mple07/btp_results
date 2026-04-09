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
   
   output logic [3:0] test_present_state,// Present State of the Testing FSM
   output logic [3:0] test_output,// Calculated output during testing
   output logic [3:0] test_result,// Count of correct matches
   output logic test_done // Indicates testing completion
   
   // Testing FSM specific inputs
   input  logic [15:0] test_index,
   input  logic [3:0] test_x1,
   input  logic [3:0] test_x2,
   input  logic [3:0] test_expected_output
   
   // Gate_target interface
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
   
   logic signed [15:0] test_next_state;
   logic signed [3:0] test_action;
   
   logic signed [3:0] x1;
   logic signed [3:0] x2;
   logic signed [3:0] delta_w1;
   logic signed [3:0] delta_w2;
   logic signed [3:0] delta_b;
   logic signed [3:0] w1_reg;
   logic signed [3:0] w2_reg;
   logic signed [3:0] bias_reg;
   logic signed [3:0] test_output;
   logic signed [3:0] test_result;
   logic signed [3:0] test_done;
   logic signed [3:0] test_index;
   
   // Training FSM control signals
   logic signed [3:0] clr_en;
   logic signed [3:0] cap_en;
   logic signed [3:0] delta_en;
   logic signed [3:0] sum_en;
   
   // Testing FSM control signals
   logic signed [3:0] test_done;
   
   // Testing vectors
   logic signed [15:0] test_inputs_x1 [15:0];
   logic signed [15:0] test_inputs_x2 [15:0];
   logic signed [3:0] test_expected_outputs [15:0];
   
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
   
   always_ff@(posedge clk or negedge rst) begin
       if(!rst) begin
          present_state <= S0;
          iteration <= 0;
        end else
          present_state <= next_state;
   end

   always_comb begin
        next_state = present_state;
        
     case(present_state)
             S0  : begin 
                      if(start)
                         next_state = S1;
                      else
                         next_state = S0;
                   end
             S1  : begin 
                         next_state = S2;
                   end
             S2  : begin 
                      if(iteration == 0)
                        next_state = S3;
                     else if(iteration == 1)
                        next_state = S4;
                     else if(iteration == 2)
                        next_state = S5;
                     else 
                        next_state = S6;
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
             S8  : begin
                         next_state = S9;
                  end
             S9  : begin
                      if(iteration < 4)
                         next_state = S1;
                      else
                         next_state = S10;
                   end
             S10 : begin
                      next_state = S0;
                   end
             default : ;
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
             S8 : begin
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 1;
                    iteration = iteration + 1;
                    target = target + 4'h0;
                  end
             S9 : begin
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 0;
                    iteration = iteration + 0;
                    target = target + 4'h0;
                  end  
             S10 : begin
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 0;
                    iteration = iteration + 0;
                    target = target + 4'h0;
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
   
   // Testing FSM
   always_comb begin
     case(test_present_state)
         S0 : begin
             test_done = 1'b0;
             test_action = test_index;
         end
         S1 : begin
             test_done = 1'b0;
             test_action = 4'b0000; // Start Testing FSM
         end
         S2 : begin
             test_done = 1'b0;
             test_action = 4'b0001; // Fetch test vector
         end
         S3 : begin
             test_done = 1'b0;
             test_action = 4'b0010; // Calculate test output
         end
         S4 : begin
             test_done = 1'b0;
             test_action = 4'b0011; // Compare test output with expected output
         end
         S5 : begin
             test_done = 1'b0;
             test_action = 4'b0100; // Increment test result
         end
         S6 : begin
             test_done = 1'b0;
             test_action = 4'b0101; // Check if all tests are done
         end
         S7 : begin
             test_done = 1'b1;
         end
         default : begin
             test_done = 1'b0;
         end
     endcase
   end
   
   // Microcode control logic
   // (Microcode ROM and decoding logic to be implemented as per design requirements)
   
endmodule
