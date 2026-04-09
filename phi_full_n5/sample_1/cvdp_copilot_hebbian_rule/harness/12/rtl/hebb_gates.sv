module hebb_gates(
   input  logic               clk,
   input  logic               rst,
   input  logic               start, // To start the FSM
   input  logic  signed [3:0] a, // First Input
   input  logic  signed [3:0] b, // Second Input
   input  logic         [1:0] gate_select, // To provide the targets for a selected gate in order to train
   input  logic       done, // To indicate completion of training
   output logic  signed [3:0] w1, // Weight 1 obtained by training
   output logic  signed [3:0] w2, // Weight 2 obtained by training
   output logic  signed [3:0] bias,// Bias obtained by training
   output logic [3:0] present_state,// Present State of the Training FSM
   output logic [3:0] next_state // Next_State of the Training FSM
   output logic [3:0] test_present_state,// Present State of the Testing FSM
   output logic [3:0] test_output,// Calculated output during testing
   output logic [3:0] test_result,// Count of correct matches
   output logic test_done // Indicates testing completion
   
   // Test vectors
   logic [15:0] test_inputs_x1,
   logic [15:0] test_inputs_x2,
   logic [15:0] test_expected_outputs
   
   // Gate-specific testing scenarios
   logic [3:0] test_index,
   logic [3:0] test_next_state
   
   // Testing FSM control signals
   logic clr_en,
   logic cap_en,
   logic delta_en,
   logic sum_en,
   logic done
   
   // Training FSM control signals
   logic signed [3:0] x1,
   logic signed [3:0] x2,
   logic signed [3:0] delta_w1,
   logic signed [3:0] delta_w2,
   logic signed [3:0] delta_b,
   logic signed [3:0] w1_reg,
   logic signed [3:0] w2_reg,
   logic signed [3:0] bias_reg,
   logic signed [1:0] target
   
   // Microcode ROM for Testing FSM
   logic [15:0] test_microcode[5:0]
   
   // Gate target module
   logic signed [3:0] t1;
   logic signed [3:0] t2;
   logic signed [3:0] t3;
   logic signed [3:0] t4;
   
   gate_target dut(
       .gate_select(gate_select),
       .o_1(t1),
       .o_2(t2),
       .o_3(t3),
       .o_4(t4)
   );
   
   // Test vectors
   logic [15:0] test_x1,
   logic [15:0] test_x2,
   logic [15:0] test_expected_output
   
   // Microcode control signals
   logic [15:0] test_action
   
   // Testing FSM states
   localparam [3:0] S0 = 4'd0,
   localparam [3:0] S1 = 4'd1,
   localparam [3:0] S2 = 4'd2,
   localparam [3:0] S3 = 4'd3,
   localparam [3:0] S4 = 4'd4,
   localparam [3:0] S5 = 4'd5,
   localparam [3:0] S6 = 4'd6,
   localparam [3:0] S7 = 4'd7,
   localparam [3:0] S8 = 4'd8,
   localparam [3:0] S9 = 4'd9,
   localparam [3:0] S10 = 4'd10,
   localparam [3:0] TS0 = 4'd11,
   localparam [3:0] TS1 = 4'd12,
   localparam [3:0] TS2 = 4'd13,
   localparam [3:0] TS3 = 4'd14,
   localparam [3:0] TS4 = 4'd15,
   localparam [3:0] TS5 = 4'd16,
   localparam [3:0] TS6 = 4'd17,
   localparam [3:0] TS7 = 4'd18,
   localparam [3:0] TS8 = 4'd19,
   localparam [3:0] TS9 = 4'd20,
   localparam [3:0] TS10 = 4'd21
   
   // Initialize test vectors
   initial begin
     test_inputs_x1 = 16'h0000;
     test_inputs_x2 = 16'h0000;
     test_expected_outputs = 16'h0000;
   end
   
   // Testing FSM
   always_comb begin
     case(test_present_state)
       TS0: begin
         test_next_state = TS1;
         test_action = test_x1;
       end
       TS1: begin
         test_next_state = TS2;
         test_action = test_x2;
       end
       TS2: begin
         test_next_state = TS3;
         test_action = test_calc;
       end
       TS3: begin
         test_next_state = TS4;
         test_action = compare;
       end
       TS4: begin
         test_next_state = TS5;
         test_action = increment_index;
       end
       TS5: begin
         test_next_state = TS6;
         test_action = reset_test_index;
       end
       TS6: begin
         test_next_state = TS7;
         test_action = done;
       end
       TS7: begin
         test_next_state = TS8;
         test_action = done;
       end
       TS8: begin
         test_next_state = TS9;
         test_action = done;
       end
       TS9: begin
         test_next_state = TS10;
         test_action = done;
       end
       TS10: begin
         test_next_state = S0;
         test_action = done;
       end
       default: test_next_state = S0;
       test_action = done;
     endcase
   end
   
   // Testing FSM actions
   always_comb begin
     case(test_action)
       test_x1: begin
         test_x1 = test_inputs_x1;
       end
       test_x2: begin
         test_x2 = test_inputs_x2;
       end
       test_calc: begin
         test_calc = w1 * test_x1 + w2 * test_x2 + bias;
       end
       compare: begin
         test_output = (test_calc > 0) ? 4'd1 : 4'd-1;
         test_result = (test_output == test_expected_output) ? 4'd1 : 4'd0;
       end
       increment_index: begin
         test_index = test_index + 4'd1;
       end
       reset_test_index: begin
         test_index = TS10;
       end
       done: begin
         done = 1'b1;
       end
     endcase
   end
   
   // Training FSM
   always_comb begin
     if(done) begin
       present_state <= S10;
       next_state <= S0;
     end else begin
       present_state <= next_state;
     end
   end
   
   always_ff@(posedge clk or negedge rst) begin
     if(!rst) begin
        present_state <= S0;
        iteration <= 0;
     end else begin
        present_state <= next_state;
     end
   end

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
   
   // Gate target module instantiation
   gate_target dut(
       .gate_select(gate_select),
       .o_1(t1),
       .o_2(t2),
       .o_3(t3),
       .o_4(t4)
   );
   
   // Testing vectors instantiation
   logic signed [3:0] test_x1,
   logic signed [3:0] test_x2;
   logic signed [3:0] test_expected_output;
   
   // Microcode ROM for Testing FSM
   logic [15:0] test_microcode[5:0] = {
     {4'b0000000000000000}, // TS0, test_x1, test_x2
     {4'b0000000000000001}, // TS1, test_calc, compare
     {4'b0000000000000100}, // TS2, test_x2, increment_index
     {4'b0000000000001001}, // TS3, test_calc, reset_test_index
     {4'b0000000000010010}, // TS4, test_calc, done
     {4'b0000000000010011}, // TS5, test_calc, done
     {4'b0000000000100110}, // TS6, test_calc, done
     {4'b0000000000100111}, // TS7, test_calc, done
     {4'b0000000001001110}, // TS8, test_calc, done
     {4'b0000000001001111}  // TS9, test_calc, done
   };
   
   // Testing FSM logic
   always_comb begin
     case(test_present_state)
       TS0: begin
         clr_en = 1;
         cap_en = 0;
         delta_en = 0;
         sum_en = 0;
         iteration = 0;
         test_index = TS1;
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
         target = t1;
       end
       S3 : begin
         clr_en = 0;
         cap_en = 0;
         delta_en = 0;
         sum_en = 0;
         iteration = iteration + 0;
         target = t2;
       end
       S4 : begin
         clr_en = 0;
         cap_en = 0;
         delta_en = 0;
         sum_en = 0;
         iteration = iteration + 0;
         target = t3;
       end
       S5 : begin
         clr_en = 0;
         cap_en = 0;
         delta_en = 0;
         sum_en = 0;
         iteration = iteration + 0;
         target = t4;
       end
       S6 : begin
         clr_en = 0;
         cap_en = 0;
         delta_en = 0;
         sum_en = 0;
         iteration = iteration + 0;
         target = t5;
       end
       S7 : begin
         clr_en = 0;
         cap_en = 0;
         delta_en = 1;
         sum_en = 0;
         iteration = iteration + 0;
         target = test_expected_outputs[test_index];
       end
       S8 : begin
         clr_en = 0;
         cap_en = 0;
         delta_en = 0;
         sum_en = 1;
         iteration = iteration + 1;
         test_calc = w1 * test_x1 + w2 * test_x2 + bias;
       end
       S9 : begin
         clr_en = 0;
         cap_en = 0;
         delta_en = 0;
         sum_en = 0;
         iteration = iteration + 0;
         test_index = test_index + 4'd1;
       end
       TS10: begin
         clr_en = 0;
         cap_en = 0;
         delta_en = 0;
         sum_en = 0;
         test_done = 1'b1;
       end
       default : begin
         clr_en = 0;
         cap_en = 0;
         delta_en = 0;
         sum_en = 0;
         iteration = 0;
         test_index = TS10;
       end
     endcase
   end
   assign w1 = w1_reg;
   assign w2 = w2_reg;
   assign bias = bias_reg;
   assign test_present_state = test_present_state;
   assign test_output = test_output;
   assign test_result = test_result;
   assign test_done = test_done;
endmodule
