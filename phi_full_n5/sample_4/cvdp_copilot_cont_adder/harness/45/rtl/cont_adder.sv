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
  output logic signed [DATA_WIDTH-1:0] threshold_1,
  output logic signed [DATA_WIDTH-1:0] threshold_2,
  output logic signed [DATA_WIDTH-1:0] threshold_3,
  output logic                         sum_ready
);

  typedef enum logic [1:0] {IDLE, ACCUM, DONE} state_t;
  logic state;
  logic signed [DATA_WIDTH-1:0] sum_accum;
  logic [15:0] sample_count;
  logic signed [DATA_WIDTH-1:0] new_sum;
  logic signed [DATA_WIDTH-1:0] sat_sum;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      sum_accum <= 0;
      sample_count <= 0;
      sat_sum <= 0;
      state <= IDLE;
      sum_ready <= 0;
    end else if (accum_clear) begin
      sum_accum <= 0;
      sample_count <= 0;
      state <= IDLE;
      sum_ready <= 0;
    end else if (enable && data_valid) begin
      case (state)
        IDLE: begin
          sum_accum <= sat_sum;
          sample_count <= 1;
          state <= ACCUM;
        end
        ACCUM: begin
          if (WEIGHT == 1)
            sum_accum <= data_in;
          else
            sum_accum <= data_in * WEIGHT;
          sat_sum <= sum_accum;
          sample_count <= sample_count + 1;
          if (ACCUM_MODE == 1) begin
            if (sample_count >= window_size)
              state <= DONE;
          end else if (((sat_sum >= THRESHOLD_VALUE_1) || (sat_sum <= -THRESHOLD_VALUE_1)) ||
                    ((sat_sum >= THRESHOLD_VALUE_2) || (sat_sum <= -THRESHOLD_VALUE_2)) ||
                    ((sat_sum >= THRESHOLD_VALUE_3) || (sat_sum <= -THRESHOLD_VALUE_3))
            state <= DONE;
          end
        end
        DONE: begin
          sum_accum <= sat_sum;
          sample_count <= 0;
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
        end
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
        sum_out <= sat_sum;
        avg_out <= (ACCUM_MODE == 1) ? (sum_accum / sample_count) : 0;
        sum_ready <= 1;
      end
    end
  end

endmodule
