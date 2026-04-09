module hebb_gates(
   input  logic               clk,
   input  logic               rst,
   input  logic               start, // To start the FSM
   input  logic  signed [3:0] a, // First Input
   input  logic  signed [3:0] b, // Second Input
   input  logic         [1:0] gate_select, // To provide the targets for a selected gate in order to train
   input  logic         done, // Flag for the Testing FSM to start
   output logic  signed [3:0] w1, // Weight 1 obtained by training
   output logic  signed [3:0] w2, // Weight 2 obtained by training
   output logic  signed [3:0] bias,// Bias obtained by training
   output logic [3:0] present_state,// Present State of the Training FSM
   output logic [3:0] next_state // Next_State of the Training FSM
   
   output logic [3:0] test_present_state,// Current state of the Testing FSM
   output logic [3:0] test_output,// Calculated output during testing
   output logic [3:0] test_result,// Count of correct matches
   output logic test_done // Indicates testing completion
   
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
   localparam [3:0] TEST_S2 = 4'd13;
   localparam [3:0] TEST_S3 = 4'd14;
   localparam [3:0] TEST_S4 = 4'd15;
   localparam [3:0] TEST_S5 = 4'd16;
   localparam [3:0] TEST_S6 = 4'd17;
   localparam [3:0] TEST_S7 = 4'd18;
   localparam [3:0] TEST_S8 = 4'd19;
   localparam [3:0] TEST_S9 = 4'd20;
   localparam [3:0] TEST_S10 = 4'd21;
   
   logic signed [3:0] x1;
   logic signed [3:0] x2;
   logic signed [3:0] delta_w1;
   logic signed [3:0] delta_w2;
   logic signed [3:0] delta_b;
   logic signed [3:0] w1_reg;
   logic signed [3:0] w2_reg;
   logic signed [3:0] bias_reg;
   logic signed [15:0] test_index;
   logic signed [3:0] test_result;
   logic signed [3:0] test_output;
   logic signed [3:0] test_present_state;
   logic signed [3:0] test_done;
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
        end else if(done) begin
          present_state <= TEST_S0; // Transition to Testing FSM upon training completion
        end
        next_state <= present_state;
   end

   always_comb begin
        test_present_state <= present_state;
        test_index <= test_index;
        test_result <= 4'b0000;
        test_output <= 4'b0000;
   end

   always_comb begin
        case(test_present_state)
             TEST_S0 : begin 
                    clr_en = 1;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en   = 0;
                    test_done = 1'b0; // Testing phase initiation
                    test_index <= test_index;
                   end
             TEST_S1 : begin 
                    clr_en = 0;
                    cap_en = 1;
                    delta_en = 0;
                    sum_en = 0;
                    test_index <= test_index + 4'h0;
                   end
             TEST_S2 : begin 
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 0;
                    test_index <= test_index + 4'h0;
                   end
             TEST_S3 : begin 
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 0;
                    test_index <= test_index + 4'h0;
                   end
             TEST_S4 : begin 
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 0;
                    test_index <= test_index + 4'h0;
                   end
             TEST_S5 : begin
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 0;
                    test_index <= test_index + 4'h0;
                   end
             TEST_S6 : begin
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 0;
                    test_index <= test_index + 4'h0;
                   end
             TEST_S7 : begin
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 1;
                    sum_en = 1;
                    test_index <= test_index + 4'h0;
                   end
             TEST_S8 : begin
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 0;
                    test_index <= test_index + 4'h0;
                   end
             TEST_S9 : begin
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 0;
                    test_index <= test_index + 4'h0;
                   end
             TEST_S10 : begin
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 0;
                    test_index <= test_index + 4'h0;
                   end
             default : begin
                    clr_en = 0;
                    cap_en = 0;
                    delta_en = 0;
                    sum_en = 0;
                    test_done = 1'b0; // Completion of Testing FSM
                    test_index = 4'h0;
                   end
        endcase
   end
   
   assign w1 = w1_reg;
   assign w2 = w2_reg;
   assign bias = bias_reg;
   
   // Testing FSM implemented using microcode
   always_comb begin
     case(test_present_state)
         TEST_S0 : begin
             test_output = test_output;
             test_done = 1'b0;
         end
         TEST_S1 : begin
             test_output = (w1 * test_x1) + (w2 * test_x2) + bias;
             test_done = 1'b0;
         end
         TEST_S2 : begin
             test_output = (w1 * test_x1) + (w2 * test_x2) + bias;
             test_done = 1'b0;
         end
         TEST_S3 : begin
             // Fetch next test vector
             test_x1 = test_inputs_x1[test_index];
             test_x2 = test_inputs_x2[test_index];
             test_index = test_index + 4'h0;
             test_done = 1'b0;
         end
         TEST_S4 : begin
             // Perform calculation
             test_output = (w1 * test_x1) + (w2 * test_x2) + bias;
             test_done = 1'b0;
         end
         TEST_S5 : begin
             // Verify result
             if (test_output == test_expected_outputs[test_index]) begin
                 test_result <= test_result + 4'b0001;
             end else begin
                 test_result <= test_result + 4'b0000;
             end
             test_done = 1'b0;
         end
         default : begin
             test_output = 4'b0000;
             test_done = 1'b0;
         end
     endcase
   end

endmodule
