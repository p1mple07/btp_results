module cont_adder #(
  parameter DATA_WIDTH = 32,
  parameter signed THRESHOLD_VALUE_1 = 50,
  parameter signed THRESHOLD_VALUE_2 = 100,
  parameter signed THRESHOLD_VALUE_3 = 150,
  parameter ACCUM_MODE = 0,
  parameter WEIGHT = 1,
  parameter signed SAT_MAX = (2**(DATA_WIDTH-1))-1,
  parameter signed SAT_MIN = -(2**(DATA_WIDTH-1))
) (
  input  logic                         clk,
  input  logic                         reset,
  input  logic                         accum_clear,
  input  logic                         enable,
  input  logic signed [DATA_WIDTH-1:0] data_in,
  input  logic                         data_valid,
  input  logic [15:0]                  window_size,
  output logic signed [DATA_WIDTH-1:0] sum_out,
  output logic signed [DATA_WIDTH-1:0] avg_out,
  output logic                         threshold_1,
  output logic                         threshold_2,
  output logic                         threshold_3,
  output logic                         sum_ready,
  output logic                         busy
);

  typedef enum logic [1:0] {IDLE, ACCUM, DONE} state_t;
  state_t state;
  logic signed [DATA_WIDTH-1:0] sum_accum;
  logic [15:0] sample_count;
  logic signed [DATA_WIDTH-1:0] weighted_in_reg;
  logic signed [DATA_WIDTH-1:0] sat_sum;

  // -----------------------------------------------------------------
  // Merged always_ff block for weighted_in_reg and sat_sum.
  // This reduces one register and associated combinational logic.
  // -----------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      weighted_in_reg <= 0;
      sat_sum         <= 0;
    end else if (enable && data_valid) begin
      // Use a single ternary to select weighted input.
      weighted_in_reg <= (WEIGHT == 1) ? data_in : data_in * WEIGHT;
      // Compute saturated sum using a nested ternary.
      sat_sum <= (sum_accum + weighted_in_reg) > SAT_MAX ? SAT_MAX :
                 ((sum_accum + weighted_in_reg) < SAT_MIN ? SAT_MIN :
                  (sum_accum + weighted_in_reg));
    end
  end

  // -----------------------------------------------------------------
  // State machine and accumulation logic.
  // -----------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state         <= IDLE;
      sum_accum     <= 0;
      sample_count  <= 0;
    end else if (accum_clear) begin
      state         <= IDLE;
      sum_accum     <= 0;
      sample_count  <= 0;
    end else if (enable && data_valid) begin
      case (state)
        IDLE: begin
          state         <= ACCUM;
          sum_accum     <= sat_sum;
          sample_count  <= 1;
        end
        ACCUM: begin
          sum_accum     <= sat_sum;
          sample_count  <= sample_count + 1;
          if (ACCUM_MODE == 1) begin
            if (sample_count + 1 >= window_size)
              state <= DONE;
          end else begin
            if (((sat_sum >= THRESHOLD_VALUE_1) || (sat_sum <= -THRESHOLD_VALUE_1)) ||
                ((sat_sum >= THRESHOLD_VALUE_2) || (sat_sum <= -THRESHOLD_VALUE_2)) ||
                ((sat_sum >= THRESHOLD_VALUE_3) || (sat_sum <= -THRESHOLD_VALUE_3)))
              state <= DONE;
          end
        end
        DONE: begin
          state         <= IDLE;
          sum_accum     <= 0;
          sample_count  <= 0;
        end
        default: state <= IDLE;
      endcase
    end
  end

  // -----------------------------------------------------------------
  // Output logic with threshold computation using an absolute value.
  // The absolute value is computed only once to reduce combinational logic.
  // Note: THRESHOLD_VALUE_x are extended to DATA_WIDTH+1 bits for proper comparison.
  // -----------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      sum_out      <= 0;
      avg_out      <= 0;
      sum_ready    <= 0;
      threshold_1  <= 0;
      threshold_2  <= 0;
      threshold_3  <= 0;
      busy         <= 0;
    end else begin
      busy <= (state == ACCUM);
      if (state == DONE) begin
        sum_out <= sum_accum;
        avg_out <= (ACCUM_MODE == 1) ? (sum_accum / sample_count) : 0;
        sum_ready <= 1;
        // Compute absolute value of sum_accum.
        logic signed [DATA_WIDTH:0] abs_sum;
        abs_sum = (sum_accum[DATA_WIDTH-1]) ? -sum_accum : sum_accum;
        // Compare against extended threshold values.
        threshold_1 <= (abs_sum >= {1'b0, THRESHOLD_VALUE_1});
        threshold_2 <= (abs_sum >= {1'b0, THRESHOLD_VALUE_2});
        threshold_3 <= (abs_sum >= {1'b0, THRESHOLD_VALUE_3});
      end else begin
        sum_out      <= 0;
        avg_out      <= 0;
        sum_ready    <= 0;
        threshold_1  <= 0;
        threshold_2  <= 0;
        threshold_3  <= 0;
      end
    end
  end

endmodule