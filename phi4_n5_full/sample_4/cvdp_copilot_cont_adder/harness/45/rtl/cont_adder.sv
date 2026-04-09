
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
  logic signed [DATA_WIDTH-1:0] new_sum;
  logic signed [DATA_WIDTH-1:0] sat_sum;

  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      weighted_in_reg <= 0;
    else if (enable && data_valid) begin
      if (WEIGHT == 1)
        weighted_in_reg <= data_in;
      else
        weighted_in_reg <= data_in * WEIGHT;
    end else
      weighted_in_reg <= weighted_in_reg;
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      new_sum <= 0;
      sat_sum <= 0;
    end else if (enable && data_valid) begin
      new_sum <= sum_accum + weighted_in_reg;
      if ((sum_accum + weighted_in_reg) > SAT_MAX)
        sat_sum <= SAT_MAX;
      else if ((sum_accum + weighted_in_reg) < SAT_MIN)
        sat_sum <= SAT_MIN;
      else
        sat_sum <= sum_accum + weighted_in_reg;
    end
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      sum_accum <= 0;
      sample_count <= 0;
    end else if (accum_clear) begin
      state <= IDLE;
      sum_accum <= 0;
      sample_count <= 0;
    end else if (enable && data_valid) begin
      case (state)
        IDLE: begin
          state <= ACCUM;
          sum_accum <= sat_sum;
          sample_count <= 1;
        end
        ACCUM: begin
          sum_accum <= sat_sum;
          sample_count <= sample_count + 1;
          if (ACCUM_MODE == 1) begin
            if ((sample_count + 1) >= window_size)
              state <= DONE;
          end else begin
            if (((sat_sum >= THRESHOLD_VALUE_1) || (sat_sum <= -THRESHOLD_VALUE_1)) ||
                ((sat_sum >= THRESHOLD_VALUE_2) || (sat_sum <= -THRESHOLD_VALUE_2)) ||
                ((sat_sum >= THRESHOLD_VALUE_3) || (sat_sum <= -THRESHOLD_VALUE_3)))
              state <= DONE;
          end
        end
        DONE: begin
          state <= IDLE;
          sum_accum <= 0;
          sample_count <= 0;
        end
        default: state <= IDLE;
      endcase
    end
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      sum_out <= 0;
      avg_out <= 0;
      sum_ready <= 0;
      threshold_1 <= 0;
      threshold_2 <= 0;
      threshold_3 <= 0;
      busy <= 0;
    end else begin
      busy <= (state == ACCUM);
      if (state == DONE) begin
        sum_out <= sum_accum;
        avg_out <= (ACCUM_MODE == 1) ? (sum_accum / sample_count) : 0;
        sum_ready <= 1;
        if ((sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1))
          threshold_1 <= 1;
        else
          threshold_1 <= 0;
        if ((sum_accum >= THRESHOLD_VALUE_2) || (sum_accum <= -THRESHOLD_VALUE_2))
          threshold_2 <= 1;
        else
          threshold_2 <= 0;
        if ((sum_accum >= THRESHOLD_VALUE_3) || (sum_accum <= -THRESHOLD_VALUE_3))
          threshold_3 <= 1;
        else
          threshold_3 <= 0;
      end else begin
        sum_out <= 0;
        avg_out <= 0;
        sum_ready <= 0;
        threshold_1 <= 0;
        threshold_2 <= 0;
        threshold_3 <= 0;
      end
    end
  end

endmodule
