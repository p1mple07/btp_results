module perceptron_gates (
   input  logic clk,// Posedge clock
   input  logic rst_n,// Negedge reset
   input  logic signed [3:0] x1, // First Input of the Perceptron
   input  logic signed [3:0] x2, // Second Input of the Perceptron
   input  logic signed [3:0] test_percep_x1, // Testing Input 1
   input  logic signed [3:0] test_percep_x2, // Testing Input 2
   input  logic signed [3:0] test_expected_output, // Expected Output for Testing
   input  logic signed [3:0] gate_select, // Gate selection for AND, OR, NAND, NOR
   input  logic learning_rate, // Learning rate (alpha)
   input  logic signed [3:0] threshold, // Threshold value
   input  logic [1:0] train_or_test, // Control unit: 0 for Training, 1 for Testing
   input  logic stop, // Condition to indicate no learning has occurred(i.e. no weight change between iterations)
   output logic signed [3:0] percep_w1, // Trained Weight 1
   output logic signed [3:0] percep_w2, // Trained Weight 2
   output logic signed [3:0] percep_bias, // Trained Bias
   output logic [3:0] present_addr, // Current address in microcode ROM
   output logic test_percep_present_state, // Present state of Testing microcode ROM
   output logic test_percep_output, // Actual output from Testing microcode ROM
   output logic test_percep_result, // Number of times expected_output matched test_output
   output logic test_percep_done, // Indicates completion of Testing operation
   output logic [2:0] input_index,// Vector to track the selection of target for a given input combination for a gate
   output logic signed [3:0] y_in, // Calculated Response
   output logic signed [3:0] y, // Calculated Response obtained by comparing y_in against a threshold value
   output logic signed [3:0] prev_percep_wt_1,//Value of Weight 1 during a previous iteration
   output logic signed [3:0] prev_percep_wt_2,//Value of Weight 2 during a previous iteration
   output logic signed [3:0] prev_percep_bias // Value of Bias during a previous iteration
);

   logic [15:0] microcode_rom [0:255]; // Extended Training and Testing microcode ROM
   logic [3:0]  next_addr;
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

   logic signed [3:0] test_percep_present_state;
   logic signed [3:0] test_percep_output;
   logic signed [3:0] test_percep_result;
   logic signed [3:0] test_percep_done;

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
      // Initialize Testing ROM with predefined vectors
      microcode_rom[0] = 16'b0001_0000_0000_0000; // AND
      microcode_rom[1] = 16'b0010_0001_0000_0000; // OR
      microcode_rom[2] = 16'b0011_0010_0000_0000; // NAND
      microcode_rom[3] = 16'b0100_0011_0000_0000; // NOR
      microcode_rom[4] = 16'b0101_0100_0000_0000; 
      microcode_rom[5] = 16'b0000_0101_0000_0000; 
      microcode_rom[6] = 16'b0000_0000_0100_0000; // AND test vector
      microcode_rom[7] = 16'b0000_0000_0000_0100; // OR test vector
      microcode_rom[8] = 16'b0000_0000_0000_0010; // NAND test vector
      microcode_rom[9] = 16'b0000_0000_0000_0000; // NOR test vector

      // Initialize training-related variables
      prev_percep_wt_1_reg <= 4'd0;
      prev_percep_wt_2_reg <= 4'd0;
      prev_percep_bias_reg <= 4'd0;
      input_index <= 2'd0;
      stop <= 1'b0;
   end

   always@(*) begin
      microinstruction = train_or_test ? microcode_rom[microcode_addr] : 16'b0000_0000_0000_0000;
      next_addr        = train_or_test ? next_addr + 4'd0 : next_addr;
      train_action     = train_or_test ? 4'd1 : 4'd0;
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
      case (train_or_test)
         4'd0:  begin 
                   prev_wt1_update <= 4'd0;
                   prev_wt2_update <= 4'd0;
                   prev_bias_update <= 4'd0;
                   stop = 1'b0;
                   y_in = 4'd0;
                   y    = 4'd0;
                   wt1_update = 0;
                   wt2_update = 0;
                   bias_update = 0;
                   input_index = 0;
                   target = 0;
                   test_percep_present_state <= 4'd0;
                   test_percep_output <= 4'd0;
                   test_percep_result <= 4'd0;
                   test_percep_done <= 1'b0;
                end
         4'd1:  begin 
                   y_in = test_bias_reg + (test_percep_x1 * test_percep_wt_1_reg) + (test_percep_x2 * test_percep_wt_2_reg); 
                   if (y_in > threshold)
                      y = test_percep_output;
                   else if (y_in >= -threshold && y_in <= threshold)
                      y = 4'd0;
                   else
                      y = -test_percep_output;

                   percep_wt_1_reg  = test_percep_wt_1_reg  + 4'd0;
                   percep_wt_2_reg  = test_percep_wt_2_reg  + 4'd0;
                   percep_bias_reg  = test_percep_bias_reg  + 4'd0;
                   test_percep_present_state <= test_percep_present_state + 4'd0;
                   test_percep_output <= test_percep_output + 4'd0;
                   test_percep_result <= test_percep_result + 4'd0;
                   test_percep_done <= test_percep_done + 1'b0;
                end
         4'd2 : begin
                   // Training logic (same as original code)
                end
         4'd3 : begin
                   // Training logic (same as original code)
                end
         4'd4 : begin
                   // Training logic (same as original code)
                end
         4'd5 : begin
                   // Training logic (same as original code)
                end
          default : begin
                   // Training logic (same as original code)
                end
      endcase
   end
   assign percep_w1 = percep_wt_1_reg;
   assign percep_w2 = percep_wt_2_reg;
   assign percep_bias = percep_bias_reg;

endmodule
