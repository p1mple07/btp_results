module perceptron_gates (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic signed [3:0]     x1,
    input  logic signed [3:0]     x2,
    input  logic                  learning_rate,
    input  logic signed [3:0]     threshold,
    input  logic [1:0]            gate_select,
    output logic signed [3:0]     percep_w1,
    output logic signed [3:0]     percep_w2,
    output logic signed [3:0]     percep_bias,
    output logic [3:0]            present_addr,
    output logic                  stop,
    output logic [2:0]            input_index,
    output logic signed [3:0]     y_in,
    output logic signed [3:0]     y,
    output logic signed [3:0]     prev_percep_wt_1,
    output logic signed [3:0]     prev_percep_wt_2,
    output logic signed [3:0]     prev_percep_bias
);

  // Define microcode action codes
  localparam INIT              = 4'd0;
  localparam COMPUTE           = 4'd1;
  localparam SELECT_TARGET     = 4'd2;
  localparam UPDATE            = 4'd3;
  localparam CONVERGENCE_CHECK = 4'd4;
  localparam FINALIZE          = 4'd5;

  // Microcode ROM: sequence of 6 micro-instructions.
  // The ROM maps the current state to the next state.
  parameter logic [3:0] microcode_rom [0:5] = '{ 
      COMPUTE,           // INIT (0) -> COMPUTE (1)
      SELECT_TARGET,     // COMPUTE (1) -> SELECT_TARGET (2)
      UPDATE,            // SELECT_TARGET (2) -> UPDATE (3)
      CONVERGENCE_CHECK, // UPDATE (3) -> CONVERGENCE_CHECK (4)
      FINALIZE,          // CONVERGENCE_CHECK (4) -> FINALIZE (5)
      INIT               // FINALIZE (5) -> INIT (0) to start new epoch
  };

  //-------------------------------------------------------------------------
  // Register Declarations
  //-------------------------------------------------------------------------
  reg  [3:0] state, next_state;
  reg signed [3:0] percep_w1_reg, percep_w2_reg, percep_bias_reg;
  reg signed [3:0] prev_percep_wt_1_reg, prev_percep_wt_2_reg, prev_percep_bias_reg;
  reg signed [3:0] y_in_reg, y_reg;
  reg signed [3:0] target;
  reg signed [3:0] wt1_update_reg, wt2_update_reg, bias_update_reg;
  reg signed [3:0] t1, t2, t3, t4;
  reg  [2:0] input_index_reg;
  reg stop_reg;

  //-------------------------------------------------------------------------
  // Output Assignments
  //-------------------------------------------------------------------------
  assign percep_w1      = percep_w1_reg;
  assign percep_w2      = percep_w2_reg;
  assign percep_bias    = percep_bias_reg;
  assign present_addr   = state;
  assign stop           = stop_reg;
  assign input_index    = input_index_reg;
  assign y_in           = y_in_reg;
  assign y              = y_reg;
  assign prev_percep_wt_1 = prev_percep_wt_1_reg;
  assign prev_percep_wt_2 = prev_percep_wt_2_reg;
  assign prev_percep_bias = prev_percep_bias_reg;

  //-------------------------------------------------------------------------
  // Next State Combinational Logic (Microcode ROM)
  //-------------------------------------------------------------------------
  always_comb begin
    next_state = microcode_rom[state];
  end

  //-------------------------------------------------------------------------
  // Sequential Process: Microcoded Controller
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Asynchronous reset: initialize all registers
      state             <= INIT;
      percep_w1_reg     <= 0;
      percep_w2_reg     <= 0;
      percep_bias_reg   <= 0;
      prev_percep_wt_1_reg <= 0;
      prev_percep_wt_2_reg <= 0;
      prev_percep_bias_reg <= 0;
      y_in_reg          <= 0;
      y_reg             <= 0;
      target            <= 0;
      wt1_update_reg    <= 0;
      wt2_update_reg    <= 0;
      bias_update_reg   <= 0;
      t1                <= 0;
      t2                <= 0;
      t3                <= 0;
      t4                <= 0;
      input_index_reg   <= 0;
      stop_reg          <= 0;
    end
    else begin
      // Execute action based on current microcode state
      case (state)
        INIT: begin
          // Weight and bias initialization
          percep_w1_reg     <= 0;
          percep_w2_reg     <= 0;
          percep_bias_reg   <= 0;
        end

        COMPUTE: begin
          // Compute the perceptron output (unthresholded)
          y_in_reg <= percep_bias_reg + (percep_w1_reg * x1) + (percep_w2_reg * x2);
          // Apply threshold: if y_in > threshold then y = 1; if y_in < threshold then y = -1; else y = 0.
          if (y_in_reg > threshold)
            y_reg <= 4'd1;
          else if (y_in_reg < threshold)
            y_reg <= -4'd1;
          else
            y_reg <= 4'd0;
        end

        SELECT_TARGET: begin
          // Generate target outputs based on gate_select (gate_target functionality)
          case (gate_select)
            2'b00: begin  // AND Gate: targets = (1, -1, -1, -1)
              t1 = 4'd1;  t2 = -4'd1;  t3 = -4'd1;  t4 = -4'd1;
            end
            2'b01: begin  // OR Gate: targets = (1, 1, 1, -1)
              t1 = 4'd1;  t2 = 4'd1;   t3 = 4'd1;   t4 = -4'd1;
            end
            2'b10: begin  // NAND Gate (as per spec, same as OR Gate)
              t1 = 4'd1;  t2 = 4'd1;   t3 = 4'd1;   t4 = -4'd1;
            end
            2'b11: begin  // NOR Gate: targets = (1, -1, -1, -1)
              t1 = 4'd1;  t2 = -4'd1;  t3 = -4'd1;  t4 = -4'd1;
            end
            default: begin
              t1 = 0;  t2 = 0;  t3 = 0;  t4 = 0;
            end
          endcase
          // Select the target based on input_index (0 to 3)
          case (input_index_reg)
            3'd0: target <= t1;
            3'd1: target <= t2;
            3'd2: target <= t3;
            3'd3: target <= t4;
            default: target <= 0;
          endcase
        end

        UPDATE: begin
          // Update weights and bias only if the computed output differs from the target
          if (y_reg != target) begin
            wt1_update_reg <= learning_rate * x1 * target;
            wt2_update_reg <= learning_rate * x2 * target;
            bias_update_reg <= learning_rate * target;
            percep_w1_reg  <= percep_w1_reg  + wt1_update_reg;
            percep_w2_reg  <= percep_w2_reg  + wt2_update_reg;
            percep_bias_reg<= percep_bias_reg+ bias_update_reg;
          end
          else begin
            wt1_update_reg <= 0;
            wt2_update_reg <= 0;
            bias_update_reg <= 0;
          end
        end

        CONVERGENCE_CHECK: begin
          // Check if the current weights and bias are unchanged from the previous iteration
          if ((percep_w1_reg  == prev_percep_wt_1_reg) &&
              (percep_w2_reg  == prev_percep_wt_2_reg) &&
              (percep_bias_reg == prev_percep_bias_reg))
            stop_reg <= 1;
          else
            stop_reg <= 0;
          // Update previous weights and bias for next iteration comparison
          prev_percep_wt_1_reg <= percep_w1_reg;
          prev_percep_wt_2_reg <= percep_w2_reg;
          prev_percep_bias_reg <= percep_bias_reg;
        end

        FINALIZE: begin
          // Prepare for the next input sample (epoch cycle)
          if (input_index_reg == 3'd3)
            input_index_reg <= 3'd0;
          else
            input_index_reg <= input_index_reg + 1;
        end

        default: ;
      endcase

      // Update the microcode state for the next cycle
      state <= next_state;
    end
  end

endmodule