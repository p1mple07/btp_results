// File: rtl/perceptron_gates.sv
//
// This module implements a microcoded controller for training a perceptron
// model with gate‐based target selection. It uses a 6‐instruction microcode ROM
// to perform the following actions:
//   0: Initialize weights and bias to zero.
//   1: Compute the weighted sum y_in and threshold the output to produce y.
//   2: Select the target output based on the gate type and input index.
//   3: Update weights and bias if the perceptron output differs from the target.
//   4: Check for convergence by comparing current update values with previous ones.
//   5: Finalize the epoch and prepare for the next set of inputs.
//
// The module interfaces are as follows:
//
// Inputs:
//   clk              : Positive edge-triggered clock.
//   rst_n            : Negative edge-triggered reset (active low).
//   x1, x2           : 4-bit signed perceptron inputs (only ±1 allowed).
//   learning_rate    : 1-bit learning rate.
//   threshold        : 4-bit signed threshold for output computation.
//   gate_select      : 2-bit input to select the gate type:
//                        00: AND Gate      (targets:  1, -1, -1, -1)
//                        01: OR Gate       (targets:  1,  1,  1, -1)
//                        10: NAND Gate     (targets:  1,  1,  1, -1)
//                        11: NOR Gate      (targets:  1, -1, -1, -1)
//
// Outputs:
//   percep_w1, percep_w2, percep_bias : Current perceptron weights and bias.
//   present_addr                      : Current microcode ROM address (state).
//   stop                              : Training stop signal (asserted when converged).
//   input_index                       : 3-bit index (0 to 3) for target selection.
//   y_in                              : Computed weighted sum output.
//   y                                 : Thresholded perceptron output (1, 0, or -1).
//   prev_percep_wt_1, prev_percep_wt_2, prev_percep_bias : Weights and bias from the previous iteration.
//

module perceptron_gates (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic signed [3:0]      x1,
    input  logic signed [3:0]      x2,
    input  logic                   learning_rate,
    input  logic signed [3:0]      threshold,
    input  logic [1:0]             gate_select,
    output logic signed [3:0]      percep_w1,
    output logic signed [3:0]      percep_w2,
    output logic signed [3:0]      percep_bias,
    output logic [3:0]             present_addr,
    output logic                   stop,
    output logic [2:0]             input_index,
    output logic signed [3:0]      y_in,
    output logic signed [3:0]      y,
    output logic signed [3:0]      prev_percep_wt_1,
    output logic signed [3:0]      prev_percep_wt_2,
    output logic signed [3:0]      prev_percep_bias
);

  //-------------------------------------------------------------------------
  // Internal Register Declarations
  //-------------------------------------------------------------------------
  // Current weights and bias
  logic signed [3:0] curr_w1, curr_w2, curr_bias;
  // Previous iteration weights and bias (for convergence check)
  logic signed [3:0] prev_wt1, prev_wt2, prev_bias;
  // Microcode state (ROM address)
  logic [3:0] state;
  // Next state (for clarity in state transitions)
  logic [3:0] next_state;
  // Input index for target selection (0 to 3)
  logic [2:0] input_index_reg;
  // Computed weighted sum and thresholded output
  logic signed [3:0] y_in_reg;
  // Update values for weights and bias computed in state 3
  logic signed [4:0] wt1_update_int, wt2_update_int, bias_update_int;
  // Since learning_rate is 1-bit, the product fits in 4 bits (inputs are ±1)
  logic signed [3:0] wt1_update, wt2_update, bias_update;
  // Previous update values for convergence check
  logic signed [3:0] prev_wt1_update, prev_wt2_update, prev_bias_update;
  //
  // Gate target outputs based on gate_select:
  // t1, t2, t3, t4 correspond to target outputs for input_index = 0,1,2,3.
  //
  logic signed [3:0] t1, t2, t3, t4;
  // Selected target value for the current input_index
  logic signed [3:0] target;

  //-------------------------------------------------------------------------
  // Continuous Assignments for Outputs
  //-------------------------------------------------------------------------
  assign percep_w1    = curr_w1;
  assign percep_w2    = curr_w2;
  assign percep_bias  = curr_bias;
  assign prev_percep_wt_1 = prev_wt1;
  assign prev_percep_wt_2 = prev_wt2;
  assign prev_percep_bias = prev_bias;
  assign present_addr = state;
  assign input_index  = input_index_reg;
  assign y_in         = y_in_reg;
  // y is derived from y_in_reg using the threshold in an always_comb block below.

  //-------------------------------------------------------------------------
  // Always-Comb: Gate Target Generation and y Thresholding
  //-------------------------------------------------------------------------
  always_comb begin
    // Generate target outputs based on gate_select
    case (gate_select)
      2'b00: begin
               t1 = 4'd1;  t2 = -4'd1;  t3 = -4'd1;  t4 = -4'd1;
             end
      2'b01: begin
               t1 = 4'd1;  t2 =  4'd1;  t3 =  4'd1;  t4 = -4'd1;
             end
      2'b10: begin
               t1 = 4'd1;  t2 =  4'd1;  t3 =  4'd1;  t4 = -4'd1;
             end
      2'b11: begin
               t1 = 4'd1;  t2 = -4'd1;  t3 = -4'd1;  t4 = -4'd1;
             end
      default: begin
               t1 = 4'd0;  t2 =  4'd0;  t3 =  4'd0;  t4 = 4'd0;
             end
    endcase

    // Select the target output based on input_index_reg
    case (input_index_reg)
      3'd0: target = t1;
      3'd1: target = t2;
      3'd2: target = t3;
      3'd3: target = t4;
      default: target = 4'd0;
    endcase

    // Thresholding: if y_in_reg > threshold then y = 1; if y_in_reg < threshold then y = -1;
    // If equal, y = 0.
    if (y_in_reg > threshold)
      y = 4'd1;
    else if (y_in_reg < threshold)
      y = -4'd1;
    else
      y = 4'd0;
  end

  //-------------------------------------------------------------------------
  // Always-FF: Microcode State Machine and Data Path
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Synchronous reset: initialize all registers
      state              <= 4'd0;
      input_index_reg    <= 3'd0;
      curr_w1            <= 4'd0;
      curr_w2            <= 4'd0;
      curr_bias          <= 4'd0;
      prev_wt1           <= 4'd0;
      prev_wt2           <= 4'd0;
      prev_bias          <= 4'd0;
      wt1_update         <= 4'd0;
      wt2_update         <= 4'd0;
      bias_update        <= 4'd0;
      prev_wt1_update    <= 4'd0;
      prev_wt2_update    <= 4'd0;
      prev_bias_update   <= 4'd0;
      y_in_reg           <= 4'd0;
      stop               <= 1'b0;
    end
    else begin
      case (state)
        // State 0: Initialization
        4'd0: begin
          curr_w1    <= 4'd0;
          curr_w2    <= 4'd0;
          curr_bias  <= 4'd0;
          prev_wt1   <= 4'd0;
          prev_wt2   <= 4'd0;
          prev_bias  <= 4'd0;
          wt1_update <= 4'd0;
          wt2_update <= 4'd0;
          bias_update<= 4'd0;
          prev_wt1_update <= 4'd0;
          prev_wt2_update <= 4'd0;
          prev_bias_update<= 4'd0;
          input_index_reg <= 3'd0;
          state <= 4'd1;
        end
        // State 1: Compute weighted sum (y_in)
        4'd1: begin
          y_in_reg <= curr_bias + (x1 * curr_w1) + (x2 * curr_w2);
          state <= 4'd2;
        end
        // State 2: Select target output (using gate_target combinational logic)
        4'd2: begin
          // target is determined in always_comb block
          state <= 4'd3;
        end
        // State 3: Update weights and bias if needed
        4'd3: begin
          if (y_in_reg != target) begin
            // Compute updates only if perceptron output differs from target.
            // Multiplication by learning_rate (which is 1-bit) acts as a conditional.
            wt1_update <= learning_rate ? (x1 * target) : 4'd0;
            wt2_update <= learning_rate ? (x2 * target) : 4'd0;
            bias_update<= learning_rate ? (target)     : 4'd0;
          end
          else begin
            wt1_update <= 4'd0;
            wt2_update <= 4'd0;
            bias_update<= 4'd0;
          end
          // Update current weights and bias
          curr_w1 <= curr_w1 + wt1_update;
          curr_w2 <= curr_w2 + wt2_update;
          curr_bias <= curr_bias + bias_update;
          state <= 4'd4;
        end
        // State 4: Check for convergence
        4'd4: begin
          if ((wt1_update == prev_wt1_update) && (wt2_update == prev_wt2_update) &&
              (bias_update == prev_bias_update)) begin
            // No change in update values: training has converged.
            stop <= 1'b1;
            state <= 4'd4;  // Remain in convergence state.
          end
          else begin
            // Update previous update registers for next comparison.
            prev_wt1_update <= wt1_update;
            prev_wt2_update <= wt2_update;
            prev_bias_update<= bias_update;
            state <= 4'd5;
          end
        end
        // State 5: Finalize epoch and prepare for next set of inputs
        4'd5: begin
          if (input_index_reg == 3'd3) begin
            // Completed an epoch over four inputs; start a new epoch.
            input_index_reg <= 3'd0;
            state <= 4'd0;
          end