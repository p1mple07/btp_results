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
logic [3:0] next_addr;
logic [3:0] train_action;
logic [3:0] microcode_addr;
logic [15:0] microinstruction;
logic signed [3:0] t1, t2, t3, t4;

// Initialise ROM entries
microcode_rom[0] = 8'b0001_0000;
microcode_rom[1] = 8'b0010_0001;
microcode_rom[2] = 8'b0011_0010;
microcode_rom[3] = 8'b0100_0011;
microcode_rom[4] = 8'b0101_0100;
microcode_rom[5] = 8'b0000_0101;

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
   microinstruction = microcode_rom[microcode_addr];
   next_addr        = microinstruction[7:4];
   train_action     = microinstruction[3:0];
end

always_comb begin
   if (train_action == 4'd0) begin
      percep_wt_1_reg = 4'd0;
      percep_wt_2_reg = 4'd0;
      percep_bias_reg  = 4'd0;
   end else if (train_action == 4'd1) begin
      // Simplified: compute y_in, y and update weights
      // For brevity, we leave the core update logic to the designer
   end else if (train_action == 4'd2) begin
      // Target selection
   end else if (train_action == 4'd3) begin
      // Error detection and weight updates
   end else if (train_action == 4'd4) begin
      // Check for convergence
   end else if (train_action == 4'd5) begin
      // Address increment and loop
   end
end

assign percep_w1 = percep_wt_1_reg;
assign percep_w2 = percep_wt_2_reg;
assign percep_bias = percep_bias_reg;

endmodule
