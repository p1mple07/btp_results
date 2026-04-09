module cont_adder #(
  parameter DATA_WIDTH = 32,
  parameter signed THRESHOLD_VALUE_1 = 50,
  parameter signed THRESHOLD_VALUE_2 = 100,
  parameter signed THRESHOLD_VALUE_3 = 150,
  parameter ACCUM_MODE = 0,
  parameter WEIGHT = 1
) (
  input  logic clk,
  input  logic reset,
  input  logic accum_clear,
  input  logic enable,
  input  logic signed [DATA_WIDTH-1:0] data_in,
  input  logic data_valid,
  input  logic [15:0] window_size,
  output signed [DATA_WIDTH-1:0] sum_out,
  output signed [DATA_WIDTH-1:0] avg_out,
  output signed [DATA_WIDTH-1:0] threshold_1,
  output signed [DATA_WIDTH-1:0] threshold_2,
  output signed [DATA_WIDTH-1:0] threshold_3,
  output logic sum_ready
);

  typedef enum logic [1:0] {IDLE, ACCUM, DONE} state_t;
  state_t state;
  logic signed [DATA_WIDTH-1:0] sum_accum;
  logic [DATA_WIDTH-1:0] new_sum;
  // Removed sample_count and weighted_in_reg registers

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      sum_accum <= 0;
      // Removed sample_count register
      state <= IDLE;
      sum_ready <= 0;
      threshold_1 <= 0;
      threshold_2 <= 0;
      threshold_3 <= 0;
      busy <= 0;
    end else if (accum_clear) begin
      sum_accum <= 0;
      state <= IDLE;
      sum_ready <= 0;
      threshold_1 <= 0;
      threshold_2 <= 0;
      threshold_3 <= 0;
      busy <= 0;
    end else if (enable && data_valid) begin
      case (state)
        IDLE: begin
          state <= ACCUM;
          sum_accum <= sum_accum;
          sample_count <= 1;
        end
        ACCUM: begin
          // Removed weighted_in_reg
          if (ACCUM_MODE == 1 && (sample_count == window_size ||
              (sum_accum >= THRESHOLD_VALUE_1 || sum_accum <= -THRESHOLD_VALUE_1) ||
              (sum_accum >= THRESHOLD_VALUE_2 || sum_accum <= -THRESHOLD_VALUE_2) ||
              (sum_accum >= THRESHOLD_VALUE_3 || sum_accum <= -THRESHOLD_VALUE_3))
            state <= DONE;
          else
            sum_accum <= sum_accum + data_in * WEIGHT;
          sample_count <= sample_count + 1;
        end
        DONE: begin
          sum_out <= sum_accum;
          avg_out <= (ACCUM_MODE == 1) ? (sum_accum / sample_count) : 0;
          sum_ready <= 1;
          // Threshold logic simplified
          threshold_1 <= (sum_accum >= THRESHOLD_VALUE_1) ? 1 : 0;
          threshold_2 <= (sum_accum >= THRESHOLD_VALUE_2) ? 1 : 0;
          threshold_3 <= (sum_accum >= THRESHOLD_VALUE_3) ? 1 : 0;
        end
        default: state <= IDLE;
      endcase
    end
  end

  always_ff @(posedge clk or posedge reset) begin
    busy <= (state == ACCUM);
    // Threshold_1, threshold_2, threshold_3 logic simplified
    sum_ready <= (state == DONE) ? 1 : 0;
  end

endmodule
