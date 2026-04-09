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
   output logic [3:0] present_addr, // Current address in microcode ROM
   output logic stop, // Condition to indicate no weight change between iterations
   output logic [2:0] input_index,// Vector to track the selection of target for a given input combination for a gate
   output logic signed [3:0] y_in, // Calculated Response
   output logic signed [3:0] y, // Calculated Response obtained by comparing y_in against a threshold value
   output logic signed [3:0] prev_percep_wt_1,//Value of Weight 1 during a previous iteration
   output logic signed [3:0] prev_percep_wt_2,//Value of Weight 2 during a previous iteration
   output logic signed [3:0] prev_percep_bias // Value of Bias during a previous iteration
);

   logic [7:0] microcode_rom [0:5];
   logic [3:0]  next_addr;
   logic [3:0]  train_action;
   logic [3:0]  microcode_addr;
   logic [15:0] microinstruction;
   logic signed [3:0] t1, t2, t3, t4;
   
   gate_target dut (
       .gate_select(gate_select),
       .o_1(t1),
       .o_2(t2),
       .o_3(t3),
       .o_4(t4)
   );

   logic signed [3:0] percep_wt_1_reg;
   logic signed [3:0] percep_wt_2_reg;
   logic signed [3:0] percep_bias_reg;

   logic signed [3:0] target;
   logic signed [3:0] prev_wt1_update;
   logic signed [3:0] prev_wt2_update;
   logic signed [3:0] prev_bias_update;
   
   logic signed [3:0] wt1_update;
   logic signed [3:0] wt2_update;
   logic signed [3:0] bias_update;
   logic [7:0] epoch_counter;
   
   assign  prev_percep_wt_1 = prev_wt1_update;
   assign  prev_percep_wt_2 = prev_wt2_update;
   assign  prev_percep_bias = prev_bias_update;

   initial begin 
      microcode_rom[0] = 8'b0001_0000; 
      microcode_rom[1] = 8'b0010_0001; 
      microcode_rom[2] = 8'b0011_0010; 
      microcode_rom[3] = 8'b0100_0011; 
      microcode_rom[4] = 8'b0101_0100; 
      microcode_rom[5] = 8'b0000_0101; 
   end  

   always@(*) begin
      microinstruction = microcode_rom[microcode_addr];
      next_addr        = microinstruction[7:4];
      train_action     = microinstruction[3:0];
   end

   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         present_addr    <= 4'd0;
         microcode_addr  <= 4'd0;
         percep_wt_1_reg <= 4'd0;
         percep_wt_2_reg <= 4'd0;
         percep_bias_reg <= 4'd0;
         input_index     <= 2'd0;
         stop            <= 1'b0;
      end else begin
         present_addr    <= next_addr;
         microcode_addr  <= present_addr;
      end
   end

   always_comb begin
      // Address 0: Initialize weights and bias to zero
      case(microcode_addr)
         0: 
             percep_wt_1_reg <= 4'd0;
             percep_wt_2_reg <= 4'd0;
             percep_bias_reg <= 4'd0;
             target <= 4'd0;
             wt1_update <= 4'd0;
             wt2_update <= 4'd0;
             bias_update <= 4'd0;
             stop <= 1'b0;
             y_in <= 4'd0;
             y <= 4'd0;
             next_addr <= 4'd0;
             train_action <= 4'b0000;
         1: 
             // Calculate y_in and y
             y_in <= percep_bias_reg + (x1 * percep_wt_1_reg) + (x2 * percep_wt_2_reg);
             y <= 4'd0;
             if (y_in > threshold)
                 y <= 4'd1;
             else if (y_in >= -threshold && y_in <= threshold)
                 y <= 4'd0;
             else
                 y <= -4'd1;
             next_addr <= 4'd0;
             train_action <= 4'b0001;
         2: 
             // Select target based on gate selection
             case(gate_select)
                 2'b00: target <= t1;
                 2'b01: target <= t2;
                 2'b10: target <= t3;
                 2'b11: target <= t4;
             endcase
             next_addr <= 4'd0;
             train_action <= 4'b0010;
         3: 
             // Update weights and bias if needed
             case(train_action)
                 4'b0000: wt1_update <= learning_rate * x1 * target;
                             wt2_update <= learning_rate * x2 * target;
                             bias_update <= learning_rate * target;
                 4'b0001: wt1_update <= 4'd0;
                             wt2_update <= 4'd0;
                             bias_update <= 4'd0;
             endcase
             next_addr <= 4'd0;
             train_action <= 4'b0011;
         default: 
             // No action needed
             next_addr <= 4'd0;
             train_action <= 4'b0000;
      endcase
   end

   assign percep_w1 = percep_wt_1_reg;
   assign percep_w2 = percep_wt_2_reg;
   assign percep_bias = percep_bias_reg;

endmodule