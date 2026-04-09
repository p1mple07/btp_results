module perceptron_gates (
   input  logic clk,
   input  logic rst_n,
   input  logic signed [3:0] x1,
   input  logic signed [3:0] x2,
   input  logic learning_rate,
   input  logic signed [3:0] threshold,
   input  logic [1:0] gate_select,
   output logic signed [3:0] percep_w1,
   output logic signed [3:0] percep_w2,
   output logic signed [3:0] percep_bias,
   output logic [3:0] present_addr,
   output logic stop,
   output logic [2:0] input_index,
   output logic signed [3:0] y_in,
   output logic signed [3:0] y,
   output logic signed [3:0] prev_percep_wt_1,
   output logic signed [3:0] prev_percep_wt_2,
   output logic signed [3:0] prev_percep_bias
);

   logic [7:0] microcode_rom [0:5];
   logic [3:0]  next_addr;
   logic [3:0]  train_action;
   logic [3:0]  microcode_addr;
   logic [15:0] microinstruction;
   logic signed [3:0] t1, t2, t3, t4;

   // Microcode ROM initialization
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

   // Assign next_addr and train_action from microcode_rom
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
         next_addr        = microinstruction[7:4];
         train_action     = microinstruction[3:0];
      end
   end

   // Assign train_action from microcode_rom
   always_comb begin
      if (microcode_addr == 0) begin
         train_action = 4'd0; // Initialize
      end else if (microcode_addr == 1) begin
         train_action = 4'd1; // Compute y_in
      end else if (microcode_addr == 2) begin
         train_action = 4'd2; // Compare
      end else if (microcode_addr == 3) begin
         train_action = 4'd3; // Update weights
      end else if (microcode_addr == 4) begin
         train_action = 4'd4; // Compare again
      end else begin
         train_action = 4'd5; // Done
      end
   end

   // Always_ff block for next_addr and train_action
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
         next_addr        = microinstruction[7:4];
         train_action     = microinstruction[3:0];
      end
   end

   // Assign train_action from microcode_rom
   always_comb begin
      if (microcode_addr == 1) begin
         y_in = percep_bias_reg + (x1 * percep_wt_1_reg) + (x2 * percep_wt_2_reg);
      end else if (microcode_addr == 2) begin
         y_in = percep_bias_reg + (x1 * percep_wt_1_reg) + (x2 * percep_wt_2_reg);
      end else if (microcode_addr == 3) begin
         if (y_in != target) begin
            wt1_update = learning_rate * x1 * target;
            wt2_update = learning_rate * x2 * target;
            bias_update = learning_rate * target;
         end else begin
            wt1_update = 0;
            wt2_update = 0;
            bias_update = 0;
         end
      end else if (microcode_addr == 4) begin
         if (wt1_update == prev_wt1_update) && (wt2_update == prev_wt2_update) && (bias_update == prev_bias_update) then
            stop = 1'b1;
         else
            stop = 1'b0;
      end else if (microcode_addr == 5) begin
         input_index = next_addr;
         next_addr = next_addr + 4'd1;
         next_addr = next_addr + 4'd1;
      end
   end

   assign percep_w1 = percep_wt_1_reg;
   assign percep_w2 = percep_wt_2_reg;
   assign percep_bias = percep_bias_reg;

endmodule
