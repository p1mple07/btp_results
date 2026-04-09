rtl/perceptron_gates.sv
--------------------------------------------------------------------------------
module perceptron_gates (
  input  logic                 clk,
  input  logic                 rst_n,
  input  logic signed [3:0]    x1,
  input  logic signed [3:0]    x2,
  input  logic                 learning_rate,
  input  logic signed [3:0]    threshold,
  input  logic [1:0]           gate_select,
  output logic signed [3:0]    percep_w1,
  output logic signed [3:0]    percep_w2,
  output logic signed [3:0]    percep_bias,
  output logic [3:0]           present_addr,
  output logic                 stop,
  output logic [2:0]           input_index,
  output logic signed [3:0]    y_in,
  output logic signed [3:0]    y,
  output logic signed [3:0]    prev_percep_wt_1,
  output logic signed [3:0]    prev_percep_wt_2,
  output logic signed [3:0]    prev_percep_bias
);

  //-------------------------------------------------------------------------
  // Internal registers for weights, bias, previous values, and state
  //-------------------------------------------------------------------------
  logic signed [3:0] w1, w2, bias;         // current weights and bias
  logic signed [3:0] prev_w1, prev_w2, prev_bias; // previous iteration values
  logic [2:0]       idx;                    // input index (0 to 3)
  logic [3:0]       state;                  // microcode ROM address/state
  logic signed [3:0] y_in_reg, y_reg;        // computed perceptron output (raw and thresholded)
  logic signed [3:0] target;                 // target value selected via gate_target
  // Temporary registers for update calculations
  logic signed [3:0] update_w1, update_w2, update_bias;
  
  //-------------------------------------------------------------------------
  // Gate Target Submodule
  // Generates t1, t2, t3, t4 based on gate_select:
  //  AND (00):  t1= 1, t2=-1, t3=-1, t4=-1
  //  OR  (01):   t1= 1, t2= 1, t3= 1, t4=-1
  //  NAND(10):  t1= 1, t2= 1, t3= 1, t4=-1
  //  NOR (11):   t1= 1, t2=-1, t3=-1, t4=-1
  //-------------------------------------------------------------------------
  logic signed [3:0] t1, t2, t3, t4;
  always_comb begin
    case (gate_select)
      2'b00: begin
        t1 =  4'd1; t2 = -4'd1; t3 = -4'd1; t4 = -4'd1;
      end
      2'b01: begin
        t1 =  4'd1; t2 =  4'd1; t3 =  4'd1; t4 = -4'd1;
      end
      2'b10: begin
        t1 =  4'd1; t2 =  4'd1; t3 =  4'd1; t4 = -4'd1;
      end
      2'b11: begin
        t1 =  4'd1; t2 = -4'd1; t3 = -4'd1; t4 = -4'd1;
      end
      default: begin
        t1 =  4'd0; t2 =  4'd0; t3 =  4'd0; t4 =  4'd0;
      end
    endcase
  end

  //-------------------------------------------------------------------------
  // Microcoded State Machine
  // Microcode ROM defines 6 micro-instructions:
  //  Action 0: Weight initialization (executed once at reset)
  //  Action 1: Compute y_in = bias + (x1*w1) + (x2*w2) and determine y
  //            using: if (y_in > threshold) then y=1; if (y_in < threshold) then y=-1;
  //                    if (y_in == threshold) then y=0.
  //  Action 2: Select target value based on input_index and gate type.
  //  Action 3: Update weights and bias if (y != target).
  //  Action 4: Compare current weights/bias with previous values for convergence.
  //  Action 5: Finalize update and prepare for next epoch (update input_index).
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state         <= 4'd0;
      w1            <= 4'd0;
      w2            <= 4'd0;
      bias          <= 4'd0;
      prev_w1       <= 4'd0;
      prev_w2       <= 4'd0;
      prev_bias     <= 4'd0;
      idx           <= 3'd0;
      stop          <= 1'b0;
    end
    else begin
      case (state)
        4'd0: begin
          // Action 0: Weight initialization (only at reset)
          state <= 4'd1;
        end
        4'd1: begin
          // Action 1: Compute y_in and y.
          // Use an 8-bit temporary to hold the full sum.
          logic signed [7:0] temp_y;
          temp_y = {4'd0, bias} + (x1 * w1) + (x2 * w2);
          y_in_reg <= temp_y[3:0];  // Output lower 4 bits
          if (temp_y > {4'd0, threshold})
            y_reg <= 4'd1;
          else if (temp_y < {4'd0, threshold})
            y_reg <= -4'd1;
          else
            y_reg <= 4'd0;
          state <= 4'd2;
        end
        4'd2: begin
          // Action 2: Select target value based on input_index.
          case (idx)
            3'd0: target <= t1;
            3'd1: target <= t2;
            3'd2: target <= t3;
            3'd3: target <= t4;
            default: target <= 4'd0;
          endcase
          state <= 4'd3;
        end
        4'd3: begin
          // Action 3: Update weights and bias if perceptron output differs from target.
          if (y_reg != target) begin
            update_w1 <= w1 + (learning_rate ? (x1 * target) : 4'd0);
            update_w2 <= w2 + (learning_rate ? (x2 * target) : 4'd0);
            update_bias <= bias + (learning_rate ? (target) : 4'd