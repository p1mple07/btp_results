module perceptron_gates (
   input  logic clk,// Posedge clock
   input  logic rst_n,// Negedge reset
   input  logic signed [3:0] x1, // First Input of the Perceptron
   input  logic signed [3:0] x2, // Second Input of the Perceptron
   input  logic signed [3:0] threshold, // Threshold value
   input  logic [1:0] gate_select, // Gate selection for target values
   input  logic signed [3:0] test_percep_x1, // Testing input 1
   input  logic signed [3:0] test_percep_x2, // Testing input 2
   input  logic signed [3:0] test_expected_output, // Expected output for testing
   input  logic [1:0] test_percep_present_state, // Present state of Testing microcode ROM
   input  logic [3:0] test_percep_output, // Output from Testing microcode ROM
   input  logic signed [3:0] test_percep_result, // Number of times expected_output matched with test_output
   input  logic signed [3:0] test_percep_done, // Completion of Testing operation
   output logic signed [3:0] percep_w1, // Trained Weight 1 
   output logic signed [3:0] percep_w2, // Trained Weight 2
   output logic signed [3:0] percep_bias, // Trained Bias
   output logic [3:0] present_addr, // Current address in microcode ROM
   output logic stop, // Condition to indicate no learning has occurred(i.e. no weight change between iterations)
   output logic [2:0] input_index,// Vector to track the selection of target for a given input combination for a gate
   output logic signed [3:0] y_in, // Calculated Response
   output logic signed [3:0] y, // Calculated Response obtained by comparing y_in against a threshold value
   output logic signed [3:0] prev_percep_wt_1,//Value of Weight 1 during a previous iteration
   output logic signed [3:0] prev_percep_wt_2,//Value of Weight 2 during a previous iteration
   output logic signed [3:0] prev_percep_bias // Value of Bias during a previous iteration
   // Testing inputs and expected outputs
   input  logic signed [3:0] test_percep_x1,
   input  logic signed [3:0] test_percep_x2,
   input  logic signed [3:0] test_expected_output
   // Testing control unit outputs
   output logic signed [3:0] test_percep_present_state,
   output logic signed [3:0] test_percep_output,
   output logic signed [3:0] test_percep_result,
   output logic signed [3:0] test_percep_done
);

   logic [15:0] microcode_rom [0:5];
   logic [15:0] test_microcode_rom [0:5];
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

   // Training microcode ROM
   initial begin 
      microcode_rom[0] = 16'b0001_0000_0000_0000; 
      microcode_rom[1] = 16'b0010_0001_0000_0000; 
      microcode_rom[2] = 16'b0011_0010_0000_0000; 
      microcode_rom[3] = 16'b0100_0011_0000_0000; 
      microcode_rom[4] = 16'b0101_0100_0000_0000; 
      microcode_rom[5] = 16'b0000_0101_0000_0000; 
   end  
   
   // Testing microcode ROM
   initial begin
      test_microcode_rom[0] = 16'b0001_0000_0000_0000; 
      test_microcode_rom[1] = 16'b0010_0001_0000_0000; 
      test_microcode_rom[2] = 16'b0011_0010_0000_0000; 
      test_microcode_rom[3] = 16'b0100_0011_0000_0000; 
      test_microcode_rom[4] = 16'b0101_0100_0000_0000; 
      test_microcode_rom[5] = 16'b0000_0101_0000_0000; 
   end

   always@(*) begin
      microinstruction = microcode_rom[microcode_addr];
      test_microinstruction = test_microcode_rom[test_percep_present_state];
      next_addr        = microinstruction[15:12];
      train_action     = microinstruction[11:8];
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
         test_percep_present_state <= 4'd0;
         test_percep_output <= 4'd0;
         test_percep_result <= 4'd0;
         test_percep_done       <= 4'd0;
      end else begin
         present_addr    <= next_addr;
         microcode_addr  <= present_addr;
      end
   end

   always_comb begin
      case (train_action)
         4'd0:  begin 
                   percep_wt_1_reg = 4'd0;
                   percep_wt_2_reg = 4'd0;
                   percep_bias_reg = 4'd0;
                   stop = 1'b0;
                   next_addr = next_addr + 4'd0;
                   y_in = 4'd0;
                   y    = 4'd0;
                   prev_wt1_update = 4'd0;
                   prev_wt2_update = 4'd0;
                   prev_bias_update = 4'd0;
                   input_index = 0;
                   target = 0;
                   wt1_update = 0;
                   wt2_update = 0;
                   bias_update = 0;
                   epoch_counter = 0;
                end
         4'd1: begin 
                   y_in = percep_bias_reg + (x1 * percep_wt_1_reg) + (x2 * percep_wt_2_reg); 
                   if (y_in > threshold)
                      y = 4'd1;
                   else if (y_in >= -threshold && y_in <= threshold)
                      y = 4'd0;
                   else
                      y = -4'd1;
                
                   percep_wt_1_reg  = percep_wt_1_reg  + 4'd0;
                   percep_wt_2_reg  = percep_wt_2_reg  + 4'd0;
                   percep_bias_reg  = percep_bias_reg  + 4'd0;
                   prev_wt1_update  = prev_wt1_update  + 4'd0;
                   prev_wt2_update  = prev_wt2_update  + 4'd0;
                   prev_bias_update = prev_bias_update + 4'd0;
                   input_index = input_index + 0;
                   next_addr = next_addr + 4'd0;
                   stop = stop + 1'b0;
                   target = target + 4'd0;
                   wt1_update = wt1_update + 4'd0 ;
                   wt2_update = wt2_update + 4'd0 ;
                   bias_update = bias_update + 4'd0 ;
                   epoch_counter = epoch_counter + 0;
                end
         4'd2: begin
                   if(input_index == 0)
                        target = t1;
                   else if(input_index == 1)
                        target = t2;
                   else if(input_index == 2)
                        target = t3;
                   else if(input_index == 3)
                        target = t4;
                   else begin
                        input_index = 0;
                        target = 0;
                   end
                   stop = stop + 1'b0;
                   input_index = input_index + 0;
                   next_addr = next_addr + 4'd0;
                   target = target + 4'd0;
                   prev_wt1_update  = prev_wt1_update  + 4'd0;
                   prev_wt2_update  = prev_wt2_update  + 4'd0;
                   prev_bias_update = prev_bias_update + 4'd0;
                   
                   percep_wt_1_reg = percep_wt_1_reg + 4'd0;
                   percep_wt_2_reg = percep_wt_2_reg + 4'd0;
                   percep_bias_reg = percep_bias_reg + 4'd0;
                   y_in = y_in + 4'd0;
                   y = y + 4'd0;
                   wt1_update = wt1_update + 4'd0 ;
                   wt2_update = wt2_update + 4'd0 ;
                   bias_update = bias_update + 4'd0 ;
                   epoch_counter = epoch_counter + 0;
                end
         4'd3: begin
                   if (y != target) begin
                        wt1_update = learning_rate * x1 * target ;
                        wt2_update = learning_rate * x2 * target ;
                        bias_update = learning_rate * target ; 
                    end else begin
                        wt1_update = 0 ;
                        wt2_update = 0 ;
                        bias_update = 0 ;     
                    end    
                    percep_wt_1_reg = percep_wt_1_reg + wt1_update;
                    percep_wt_2_reg = percep_wt_2_reg + wt2_update;
                    percep_bias_reg = percep_bias_reg + bias_update;
                    prev_wt1_update  = prev_wt1_update  + 4'd0;
                    prev_wt2_update  = prev_wt2_update  + 4'd0;
                    prev_bias_update = prev_bias_update + 4'd0;
                    y_in = y_in + 4'd0;
                    y = y + 4'd0;
                    stop = stop + 1'b0;
                    input_index = input_index + 0;
                    next_addr = next_addr + 4'd0;
                    target = target + 4'd0;
                    epoch_counter = epoch_counter + 0;
                end
         4'd4: begin
                  if ((prev_wt1_update == wt1_update) & (prev_wt2_update == wt2_update) & (input_index == 4'd3)) begin 
                          epoch_counter = 0;
                          stop = 1'b1; 
                          input_index = 0;
                          next_addr = 4'd0;
                          percep_wt_1_reg = 0;
                          percep_wt_2_reg = 0;
                          percep_bias_reg = 0;
                          prev_wt1_update =  0;
                          prev_wt2_update =  0;
                          prev_bias_update = 0;
                          y_in = 0;
                          y = 0;
                          target = 0;
                          test_percep_output <= 4'b0;
                          test_percep_result <= test_percep_result + 4'd1;
                          test_percep_done <= test_percep_done + 4'd1;
                  end else begin
                          stop = 1'b0; 
                          input_index = input_index + 0;
                          epoch_counter = epoch_counter + 1;    
                          next_addr = 4'd5;    
                          percep_wt_1_reg = percep_wt_1_reg + 4'd0;
                          percep_wt_2_reg = percep_wt_2_reg + 4'd0;
                          percep_bias_reg = percep_bias_reg + 4'd0;
                          prev_wt1_update = prev_wt1_update + 4'd0;
                          prev_wt2_update = prev_wt2_update + 4'd0;
                          prev_bias_update = prev_bias_update + 4'd0;
                          y_in = y_in + 4'd0;
                          y = y + 4'd0;
                          test_percep_output <= test_percep_output + 4'b0;
                          test_percep_result <= test_percep_result + 4'd1;
                          test_percep_done <= test_percep_done + 4'd1;
                  end
                end
         4'd5: begin
                          percep_wt_1_reg = percep_wt_1_reg + 4'd0;
                          percep_wt_2_reg = percep_wt_2_reg + 4'd0;
                          percep_bias_reg = percep_bias_reg + 4'd0;
                          prev_wt1_update  = wt1_update;
                          prev_wt2_update  = wt2_update;
                          prev_bias_update = bias_update;
                          next_addr = 4'd1;
                          input_index = input_index + 1;
                          stop = stop + 1'b0;
                          test_percep_output <= test_percep_output + 4'b0;
                          test_percep_result <= test_percep_result + 4'd1;
                          test_percep_done <= test_percep_done + 4'd1;
                  end
            default : begin
                          next_addr = next_addr + 4'd0;
                          percep_wt_1_reg = percep_wt_1_reg + 4'd0;
                          percep_wt_2_reg = percep_wt_2_reg + 4'd0;
                          percep_bias_reg = percep_bias_reg + 4'd0;
                          prev_wt1_update = prev_wt1_update + 4'd0;
                          prev_wt2_update = prev_wt2_update + 4'd0;
                          prev_bias_update = prev_bias_update + 4'd0;
                          stop = stop + 1'b0;
                          y_in = y_in + 4'd0;
                          y = y + 4'd0;
                          input_index = input_index + 0;
                          target = target + 4'd0;
                          wt1_update = wt1_update + 4'd0;
                          wt2_update = wt2_update + 4'd0;
                          bias_update = bias_update + 4'd0;
                          test_percep_output <= test_percep_output + 4'b0;
                          test_percep_result <= test_percep_result + 4'd1;
                          test_percep_done <= test_percep_done + 4'd1;
                  end
      endcase
   end
   assign percep_w1 = percep_wt_1_reg;
   assign percep_w2 = percep_wt_2_reg;
   assign percep_bias = percep_bias_reg;

   // Testing logic
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         test_percep_present_state <= 4'd0;
         test_percep_output <= 4'd0;
         test_percep_result <= 4'd0;
         test_percep_done <= 4'd0;
      end
   end

   assign test_percep_index = test_percep_present_state[3:0];

   assign y_in = test_percep_output;

   // Testing logic for comparison
   assign expected_percep_output = test_expected_output;

   assign test_calc = percep_w1 * test_percep_x1 + percep_w2 * test_percep_x2 + percep_bias;
   assign test_percep_output = (test_calc > threshold) ? 4'd1 : (test_calc >= -threshold && test_calc <= threshold) ? 4'd0 : -4'd1;

   assign test_percep_result = (test_percep_output == expected_percep_output) ? 4'd1 : 4'd0;

   // Mark test_percep_done when the test index reaches the terminal value for a gate
   assign test_percep_done = (test_percep_index == (gate_select ? 4 : 8));

endmodule
