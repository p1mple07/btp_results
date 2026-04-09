module cont_adder #(
  parameter DATA_WIDTH = 32,
  parameter signed THRESHOLD_VALUE_1 = 50,
  parameter signed THRESHOLD_VALUE_2 = 100,
  parameter signed THRESHOLD_VALUE_3 = 150,
  parameter ACCUM_MODE = 0,
  parameter WEIGHT = 1
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
  output logic                         sum_ready
);

  typedef enum logic [1:0] {IDLE, ACCUM, DONE} state_t;
  state_t state;
  logic signed [DATA_WIDTH-1:0] sum_accum;
  logic [15:0] sample_count;
  logic signed [DATA_WIDTH-1:0] weighted_in_reg;
  logic signed [DATA_WIDTH-1:0] new_sum;
  logic signed [DATA_WIDTH-1:0] sat_sum;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      sum_accum <= 0;
      sat_sum <= 0;
      sample_count <= 0;
    end else if (accum_clear) begin
      sum_accum <= 0;
      sample_count <= 0;
    end else if (enable && data_valid) begin
      weighted_in_reg <= data_in * WEIGHT;
      if (ACCUM_MODE) begin
        if (sample_count == window_size)
          state <= DONE;
      end else if (!ACCUM_MODE) begin
        if ((sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1) ||
             (sum_accum >= THRESHOLD_VALUE_2) || (sum_accum <= -THRESHOLD_VALUE_2) ||
             (sum_accum >= THRESHOLD_VALUE_3) || (sum_accum <= -THRESHOLD_VALUE_3))
          state <= DONE;
        else
          state <= ACCUM;
      end
      sample_count <= sample_count + 1;
    end
    sat_sum <= sum_accum + weighted_in_reg;
    sat_sum <= {SAT_MAX, sat_sum[DATA_WIDTH-1]}; // Saturate sat_sum
  end

  always_comb begin
    sum_out <= (state == DONE) ? sum_accum : 0;
    avg_out <= (ACCUM_MODE && state == DONE) ? (sum_accum / sample_count) : 0;
    threshold_1 <= (sum_accum >= THRESHOLD_VALUE_1) ? 1'b1 : 1'b0;
    threshold_2 <= (sum_accum >= THRESHOLD_VALUE_2) ? 1'b1 : 1'b0;
    threshold_3 <= (sum_accum >= THRESHOLD_VALUE_3) ? 1'b1 : 1'b0;
    sum_ready <= (state == DONE) || (state == ACCUM);
  end

endmodule
