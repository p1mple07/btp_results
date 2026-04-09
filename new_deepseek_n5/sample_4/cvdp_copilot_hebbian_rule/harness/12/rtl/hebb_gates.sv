module hebb_gates(
   input  logic  clk,
   input  logic rst,
   input  logic start,
   input  logic  signed [3:0] a,
   input  logic  signed [3:0] b,
   input  logic   [1:0] gate_select,
   output logic  signed [3:0] w1,
   output logic  signed [3:0] w2,
   output logic  signed [3:0] bias,
   output logic [3:0] present_state,
   output logic [3:0] next_state
);

   logic signed [3:0] t1, t2, t3, t4;
   logic signed [3:0] x1, x2;
   logic signed [3:0] delta_w1, delta_w2, delta_b;
   logic signed [3:0] w1_reg, w2_reg, bias_reg;
   logic [3:0] x1_reg, x2_reg;
   logic [3:0] delta_w1_reg, delta_w2_reg, delta_b_reg;
   logic signed [3:0] w1_new, w2_new, b_new;
   logic [3:0] iteration;
   logic signed [3:0] target;
   logic [3:0] present_state;
   logic [3:0] next_state;

   // Testing FSM signals
   logic [4:3] test_present_state;
   logic signed [3:0] test_output;
   logic signed [3:0] test_result;
   logic test_done;
   logic [4:3] test_index;

   // Test vectors
   parameter [15:0] test_inputs_x1 = {4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9, 4'd10, 4'd11, 4'd12, 4'd13, 4'd14, 4'd15};
   parameter [15:0] test_inputs_x2 = {4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9, 4'd10, 4'd11, 4'd12, 4'd13, 4'd14, 4'd15};
   parameter [15:0] test_expected_outputs = {4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9, 4'd10, 4'd11, 4'd12, 4'd13, 4'd14, 4'd15};

   // State Machine for Training FSM
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
  end

  // State Machine for Testing FSM
  always_comb begin
     // State Transitions
     case(test_present_state)
        S0_test: begin
            test_index = (gate_select == 2'b00) ? 4'd0 : 
                        (gate_select == 2'b01) ? 4'd4 : 
                        (gate_select == 2'b10) ? 4'd8 : 
                        (gate_select == 2'b11) ? 4'd12 : 4'd0;
            test_x1 = test_inputs_x1[test_index];
            test_x2 = test_inputs_x2[test_index];
            test_expected_output = test_expected_outputs[test_index];
            test_calc = (w1 * test_x1) + (w2 * test_x2) + bias;
            test_output = (test_calc > 0) ? 4'd1 : 4'd-1;
            test_result = (test_output == test_expected_output) ? 4'b1000 : 4'b0000;
            test_done = 0;
            test_present_state = S1_test;
        end

        S1_test: begin
            test_index = test_index + 1;
            test_x1 = test_inputs_x1[test_index];
            test_x2 = test_inputs_x2[test_index];
            test_expected_output = test_expected_outputs[test_index];
            test_calc = (w1 * test_x1) + (w2 * test_x2) + bias;
            test_output = (test_calc > 0) ? 4'd1 : 4'd-1;
            test_result = (test_output == test_expected_output) ? 4'b1000 : 4'b0000;
            test_done = (test_index == 16) ? 1 : 0;
            test_present_state = S2_test;
        end

        S2_test: begin
            test_x1 = test_inputs_x1[test_index];
            test_x2 = test_inputs_x2[test_index];
            test_expected_output = test_expected_outputs[test_index];
            test_calc = (w1 * test_x1) + (w2 * test_x2) + bias;
            test_output = (test_calc > 0) ? 4'd1 : 4'd-1;
            test_result = (test_output == test_expected_output) ? 4'b1000 : 4'b0000;
            test_done = (test_index == 16) ? 1 : 0;
            test_present_state = S3_test;
        end

        S3_test: begin
            test_x1 = test_inputs_x1[test_index];
            test_x2 = test_inputs_x2[test_index];
            test_expected_output = test_expected_outputs[test_index];
            test_calc = (w1 * test_x1) + (w2 * test_x2) + bias;
            test_output = (test_calc > 0) ? 4'd1 : 4'd-1;
            test_result = (test_output == test_expected_output) ? 4'b1000 : 4'b0000;
            test_done = (test_index == 16) ? 1 : 0;
            test_present_state = S4_test;
        end

        S4_test: begin
            test_x1 = test_inputs_x1[test_index];
            test_x2 = test_inputs_x2[test_index];
            test_expected_output = test_expected_outputs[test_index];
            test_calc = (w1 * test_x1) + (w2 * test_x2) + bias;
            test_output = (test_calc > 0) ? 4'd1 : 4'd-1;
            test_result = (test_output == test_expected_output) ? 4'b1000 : 4'b0000;
            test_done = (test_index == 16) ? 1 : 0;
            test_present_state = S0_test;
        end
     endcase
  end

  // FSM State Transitions
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

     if(sum_en) begin
        w1_reg = w1_reg + delta_w1;
        w2_reg = w2_reg + delta_w2;
        b_new = b_new + delta_b;
     end else begin
        w1_reg = w1_reg + 4'h0;
        w2_reg = w2_reg + 4'h0;
        b_new = b_new + 4'h0;
     end

     if(clr_en) begin
        w1_reg = 0;
        w2_reg = 0;
        b_new = 0;
     end else begin
        w1_reg = w1_reg + 4'h0;
        w2_reg = w2_reg + 4'h0;
        b_new = b_new + 4'h0;
     end

     if(!rst) begin
        present_state <= S0;
        iteration <= 0;
        target <= 4'd0;
     end else
        present_state <= next_state;
  end
endmodule