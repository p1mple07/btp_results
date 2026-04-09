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
  output logic signed [DATA_WIDTH-1:0] threshold_1,
  output logic signed [DATA_WIDTH-1:0] threshold_2,
  output logic signed [DATA_WIDTH-1:0] threshold_3,
  output logic sum_ready
);

  typedef enum logic [1:0] {IDLE, ACCUM, DONE} state_t;
  logic state;
  logic signed [DATA_WIDTH-1:0] sum_accum;
  logic [15:0] sample_count;
  logic signed [DATA_WIDTH-1:0] weighted_in_reg;
  logic signed [DATA_WIDTH-1:0] new_sum;
  logic signed [DATA_WIDTH-1:0] sat_sum;

  // Combined saturation check
  assign sat_sum = (sum_accum + weighted_in_reg) > SAT_MAX) | (sum_accum + weighted_in_reg) < SAT_MIN ? SAT_MAX : (sum_accum + weighted_in_reg);

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      sum_accum <= 0;
      sample_count <= 0;
      weighted_in_reg <= 0;
      sat_sum <= 0;
      state <= IDLE;
    end else if (enable && data_valid) begin
      if (WEIGHT == 1)
        weighted_in_reg <= data_in;
      else
        weighted_in_reg <= data_in * WEIGHT;
      state <= ACCUM;
    end
  end

  always_comb begin
    new_sum <= sat_sum;
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      sum_out <= 0;
      avg_out <= 0;
      sum_ready <= 0;
      threshold_1 <= 0;
      threshold_2 <= 0;
      threshold_3 <= 0;
    end else if (state == DONE) begin
      sum_out <= sum_accum;
      avg_out <= (ACCUM_MODE == 1) ? (sum_accum / sample_count) : 0;
      sum_ready <= 1;
      threshold_1 <= (abs(sum_accum) >= THRESHOLD_VALUE_1) ? 1 : 0;
      threshold_2 <= (abs(sum_accum) >= THRESHOLD_VALUE_2) ? 1 : 0;
      threshold_3 <= (abs(sum_accum) >= THRESHOLD_VALUE_3) ? 1 : 0;
    end
  end

  // State machine simplified
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
    end else if (accum_clear) begin
      state <= IDLE;
      sample_count <= 0;
    end else if (enable && data_valid) begin
      case (state)
        IDLE: begin
          state <= ACCUM;
          sample_count <= 1;
        end
        ACCUM: begin
          sum_accum <= sat_sum;
          sample_count <= sample_count + 1;
          if (ACCUM_MODE == 1 && (sample_count + 1) >= window_size ||
              ((abs(sat_sum) >= THRESHOLD_VALUE_1) || (abs(sat_sum) <= -THRESHOLD_VALUE_1) ||
              (abs(sat_sum) >= THRESHOLD_VALUE_2) || (abs(sat_sum) <= -THRESHOLD_VALUE_2) ||
              (abs(sat_sum) >= THRESHOLD_VALUE_3) || (abs(sat_sum) <= -THRESHOLD_VALUE_3))
          state <= DONE;
        end
        DONE: begin
          state <= IDLE;
          sample_count <= 0;
        end
        default: state <= IDLE;
      endcase
    end
  end

endmodule
