module hebb_gates(
   input  logic               clk,
   input  logic               rst,
   input  logic               start, // To start the FSM
   input  logic  signed [3:0] a, // First Input
   input  logic  signed [3:0] b, // Second Input
   input  logic         [1:0] gate_select, // To provide the targets for a selected gate in order to train
   input  logic  signed [3:0] w1, // Weight 1 obtained by training
   input  logic  signed [3:0] w2, // Weight 2 obtained by training
   input  logic  signed [3:0] bias,// Bias obtained by training
   input  logic [3:0] present_state,// Present State of the Training FSM
   input  logic [3:0] next_state, // Next_State of the Training FSM
   input  logic  signed [3:0] test_w1, // Test Weight 1
   input  logic  signed [3:0] test_w2, // Test Weight 2
   input  logic  signed [3:0] test_bias, // Test Bias
   input  logic  signed [15:0] test_index, // Test Index
   output logic  signed [3:0] test_output, // Calculated output during testing
   output logic  signed [3:0] test_result, // Count of correct matches
   output logic  test_done // ACTIVE HIGH Indicates testing completion
   
);
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
   
   logic [2:0] iteration;
   logic signed [3:0] x1;
   logic signed [3:0] x2;
   logic signed [3:0] delta_w1;
   logic signed [3:0] delta_w2;
   logic signed [3:0] delta_b;
   logic signed [3:0] w1_reg;
   logic signed [3:0] w2_reg;
   logic signed [3:0] bias_reg;
   logic signed [15:0] test_index;
   logic signed [3:0] test_output;
   logic signed [3:0] test_result;
   logic signed [3:0] test_done;
   logic delta_en;
   logic sum_en;
   logic clr_en;
   logic cap_en;
   
   // Training FSM
   always_comb begin
     if(cap_en ) begin
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
             S7  : begin
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
   
   // Testing FSM
   always_comb begin
      if(test_done) begin
         test_present_state <= S0;
         test_output <= 4'b0000;
         test_result <= 4'b0000;
      end else begin
         test_present_state <= test_index;
         test_output <= (test_w1 * test_x1 + test_w2 * test_x2 + test_bias > 0) ? 4'b0001 : 4'b0000;
         test_result <= (test_output == test_expected_output) ? 4'b0001 : 4'b0000;
      end
   end
   
   // Testing FSM Microcode Control
   localparam test_microcode[5:0] = '{
      {4'b0000, 4'b00, 4'b00}, // Test Initialization
      {4'b0001, 4'b01, 4'b00}, // Fetch Test Vectors
      {4'b0010, 4'b10, 4'b00}, // Perform Calculations
      {4'b0011, 4'b11, 4'b00}, // Verify Results
      {4'b0100, 4'b00, 4'b10}, // Transition to Next Test
      {4'b0101, 4'b01, 4'b10}, // Transition to Next Test
      {4'b1000, 4'b00, 4'b11}, // Mark Test Complete
   };
   
   // Control Logic for Testing FSM
   always_comb begin
     if(test_present_state == 4'b0000) begin
        test_next_state = test_microcode[test_index];
     end else begin
        test_next_state = test_microcode[test_done];
     end
   end
   
   // Gate-Specific Testing Vectors
   localparam [15:0] test_inputs_x1[15:0] = {'w':{4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111},
               test_inputs_x2[15:0] = {'w':{4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111},
               test_expected_outputs[15:0] = {'w':{4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001, 4'b0001}};
   end

   assign w1 = w1_reg;
   assign w2 = w2_reg;
   assign bias = bias_reg;
   
endmodule
