module cont_adder #(
  parameter DATA_WIDTH     = 32,
  parameter signed THRESHOLD_VALUE_1 = 50,
  parameter signed THRESHOLD_VALUE_2 = 100,
  parameter signed THRESHOLD_VALUE_3 = 150,
  parameter ACCUM_MODE     = 0,
  parameter WEIGHT         = 1,
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

  // Internal state declaration
  typedef enum logic [1:0] {IDLE, ACCUM, DONE} state_t;
  state_t state;
  logic signed [DATA_WIDTH-1:0] sum_accum;
  logic [15:0] sample_count;
  logic signed [DATA_WIDTH-1:0] weighted_in_reg;
  logic signed [DATA_WIDTH-1:0] new_sum;
  logic signed [DATA_WIDTH-1:0] sat_sum;

  // Combined sequential block for weighted input, new sum and saturation logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      weighted_in_reg <= 0;
      new_sum         <= 0;
      sat_sum         <= 0;
    end
    else if (enable && data_valid) begin
      weighted_in_reg <= (WEIGHT == 1) ? data_in : data_in * WEIGHT;
      new_sum         <= sum_accum + weighted_in_reg;
      if (new_sum > SAT_MAX)
        sat_sum <= SAT_MAX;
      else if (new_sum < SAT_MIN)
        sat_sum <= SAT_MIN;
      else
        sat_sum <= new_sum;
    end
    // No update: registers hold previous value
  end

  // Combined sequential block for state machine and output generation
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state         <= IDLE;
      sum_accum     <= 0;
      sample_count  <= 0;
      sum_out       <= 0;
      avg_out       <= 0;
      sum_ready     <= 0;
      threshold_1   <= 0;
      threshold_2   <= 0;
      threshold_3   <= 0;
      busy          <= 0;
    end
    else if (accum_clear) begin
      state         <= IDLE;
      sum_accum     <= 0;
      sample_count  <= 0;
      sum_out       <= 0;
      avg_out       <= 0;
      sum_ready     <= 0;
      threshold_1   <= 0;
      threshold_2   <= 0;
      threshold_3   <= 0;
      busy          <= 0;
    end
    else if (enable && data_valid) begin
      // State machine update with compacted assignments
      case (state)
        IDLE: begin
          state         <= ACCUM;
          sum_accum     <= sat_sum;
          sample_count  <= 1;
        end
        ACCUM: begin
          sum_accum     <= sat_sum;
          sample_count  <= sample_count + 1;
          if (ACCUM_MODE == 1)
            state <= ((sample_count + 1) >= window_size) ? DONE : ACCUM;
          else
            state <= ((((sat_sum >= THRESHOLD_VALUE_1) || (sat_sum <= -THRESHOLD_VALUE_1)) ||
                       ((sat_sum >= THRESHOLD_VALUE_2) || (sat_sum <= -THRESHOLD_VALUE_2)) ||
                       ((sat_sum >= THRESHOLD_VALUE_3) || (sat_sum <= -THRESHOLD_VALUE_3))) ? DONE : ACCUM);
        end
        DONE: begin
          state         <= IDLE;
          sum_accum     <= 0;
          sample_count  <= 0;
        end
        default: state <= IDLE;
      endcase

      // Generate outputs based on state
      busy <= (state == ACCUM);
      if (state == DONE) begin
        sum_out       <= sum_accum;
        avg_out       <= (ACCUM_MODE == 1) ? (sum_accum / sample_count) : 0;
        sum_ready     <= 1;
        threshold_1   <= ((sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1)) ? 1 : 0;
        threshold_2   <= ((sum_accum >= THRESHOLD_VALUE_2) || (sum_accum <= -THRESHOLD_VALUE_2)) ? 1 : 0;
        threshold_3   <= ((sum_accum >= THRESHOLD_VALUE_3) || (sum_accum <= -THRESHOLD_VALUE_3)) ? 1 : 0;
      end
      else begin
        sum_out       <= 0;
        avg_out       <= 0;
        sum_ready     <= 0;
        threshold_1   <= 0;
        threshold_2   <= 0;
        threshold_3   <= 0;
      end
    end
  end

endmodule