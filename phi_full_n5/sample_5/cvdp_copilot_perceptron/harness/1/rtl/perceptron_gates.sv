module perceptron_gates #(
    parameter WIDTH_INPUT = 4'd4,
    parameter WIDTH_WEIGHT = 4'd4,
    parameter WIDTH_BIAS = 4'd4,
    parameter WIDTH_TARGET = 3'd3,
    parameter WIDTH_PREV_WT = 4'd4,
    parameter WIDTH_PREV_BIAS = 4'd4
)(
    input clk,
    input rst_n,
    input [WIDTH_INPUT-1:0] x1,
    input [WIDTH_INPUT-1:0] x2,
    input [WIDTH_INPUT-1:0] threshold,
    input [WIDTH_INPUT-1:0] gate_select,
    input [WIDTH_TARGET-1:0] input_index,
    output reg [WIDTH_WEIGHT-1:0] percep_w1,
    output reg [WIDTH_WEIGHT-1:0] percep_w2,
    output reg [WIDTH_BIAS-1:0] percep_bias,
    output reg present_addr,
    output reg stop,
    output [WIDTH_PREV_WT-1:0] prev_percep_wt_1,
    output [WIDTH_PREV_WT-1:0] prev_percep_wt_2,
    output [WIDTH_PREV_BIAS-1:0] prev_percep_bias
);

  // Define submodules
  submodule gate_target(
    input [WIDTH_INPUT-1:0] x1,
    input [WIDTH_INPUT-1:0] x2,
    output [WIDTH_TARGET-1:0] o_1,
    output [WIDTH_TARGET-1:0] o_2,
    output [WIDTH_TARGET-1:0] o_3,
    output [WIDTH_TARGET-1:0] o_4
  );

  submodule microcode_rom(
    input clk,
    input [WIDTH_PREV_WT-1:0] present_addr,
    output [WIDTH_INPUT-1:0] x1_update,
    output [WIDTH_INPUT-1:0] x2_update,
    output [WIDTH_BIAS-1:0] bias_update,
    output [WIDTH_WTARGET-1:0] target
  );

  // Perceptron weights
  reg [WIDTH_WEIGHT-1:0] wt1, wt2;
  reg [WIDTH_BIAS-1:0] bias;

  // Initialize weights and bias to zero
  always @(posedge clk) begin
    if (!rst_n) begin
      wt1 = 4'd0;
      wt2 = 4'd0;
      bias = 4'd0;
    end
  end

  // Compute output
  always @(posedge clk) begin
    if (!rst_n) begin
      y_in = bias + x1_update * wt1 + x2_update * wt2;
      y = (y_in >= threshold) ? 4'd1 : (y_in < threshold) ? 4'd0 : -4'd1;
    end
  end

  // Select target value
  always @(posedge clk) begin
    if (!rst_n) begin
      case (gate_select, input_index)
        2'b00: target = {4'd1, 4'd1, 4'd1, 4'd1};
        2'b01: target = {4'd1, 4'd1, 4'd1, 4'd0};
        2'b10: target = {4'd1, 4'd1, 4'd0, 4'd1};
        2'b11: target = {4'd1, 4'd0, 4'd0, 4'd1};
        default: target = {4'd0, 4'd0, 4'd0, 4'd0};
      endcase
    end
  end

  // Update weights and bias
  always @(posedge clk) begin
    if (!rst_n) begin
      if (y != target) begin
        wt1_update = learning_rate * x1 * target[0];
        wt2_update = learning_rate * x2 * target[1];
        bias_update = learning_rate * target[2];
      end else begin
        wt1_update = 4'd0;
        wt2_update = 4'd0;
        bias_update = 4'd0;
      end
      percep_w1 = wt1 + wt1_update;
      percep_w2 = wt2 + wt2_update;
      percep_bias = bias + bias_update;
    end
  end

  // Check for convergence
  always @(posedge clk) begin
    if (!rst_n) begin
      if (wt1 == prev_wt1 && wt2 == prev_wt2 && bias == prev_bias) begin
        stop = 1'b1;
      end else begin
        prev_wt1 = wt1;
        prev_wt2 = wt2;
        prev_bias = bias;
      end
    end
  end

  // Instantiate submodules
  gate_target x1_gate(x1, x2, o_1, o_2, o_3, o_4);
  microcode_rom rom(clk, present_addr, x1_update, x2_update, bias_update, target);

endmodule
