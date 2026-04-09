module pipeline_mac #(
    parameter DWIDTH = 16,  // Bit width for multiplicand and multiplier
    parameter N      = 4    // Number of data points to accumulate over
) (
    clk,
    rstn,
    multiplicand,
    multiplier,
    valid_i,
    result,
    valid_out
);

  localparam DWIDTH_ACCUMULATOR = DWIDTH;  // Set accumulator width

  // Counters and registers
  reg [DWIDTH_ACCUMULATOR-1:0] mult_result_reg;
  reg [DWIDTH_ACCUMULATOR-1:0] accumulator_reg;
  reg [DWIDTH_ACCUMULATOR-1:0] accumulator_sum;
  reg [DWIDTH_ACCUMULATOR-1:0] multiplier_reg;
  reg [DWIDTH_ACCUMULATOR-1:0] multiplicand_reg;
  reg [DWIDTH_ACCUMULATOR-1:0] accumulator_temp;
  reg [DWIDTH_ACCUMULATOR-1:0] result_reg;

  // Counters
  reg [N-1:0] counter;
  reg [N-1:0] counter_reg;
  reg count_rst, accumulator_rst;

  // Signals
  input logic clk;
  input logic rstn;
  input logic [DWIDTH-1:0] multiplicand;
  input logic [DWIDTH-1:0] multiplier;
  input logic valid_i;
  output logic [DWIDTH_ACCUMULATOR-1:0] result;
  output logic valid_out;

  // Initialization
  initial begin
    counter <= 0;
    accumulator_reg <= 0;
    accumulator_sum <= 0;
    multiplier_reg <= 0;
    multiplicand_reg <= 0;
    accumulator_temp <= 0;
    result_reg <= 0;
    valid_out_s0 = 0;
    valid_out_s1 = 0;
    valid_out_s2 = 0;
  end

  // Stage 1: Multiplication
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      mult_result_reg <= 0;
    end else begin
      if (valid_i) begin
        if (counter < N) begin
          if (counter == 0) begin
            mult_result_reg <= multiplicand;
          end
          else begin
            mult_result_reg <= mult_result_reg + multiplicand;
          end
        end else begin
          mult_result_reg <= 0;
        end
      end else begin
        mult_result_reg <= 0;
      end
    end
  end

  // Stage 2: Accumulation
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      accumulator_reg <= 0;
    end else begin
      if (valid_i) begin
        if (counter < N) begin
          accumulator_reg <= accumulator_reg + accumulator_temp;
        end
      end else begin
        accumulator_reg <= 0;
      end
    end
  end

  // Generate final output after N accumulations
  always @(posedge clk or negedge rstn) begin
    if (counter == N) begin
      accumulator_sum <= accumulator_reg;
      accumulator_reg <= 0;
      counter <= 0;
      valid_out_s0 = 1;
    end
  end

  // Output final result
  assign result = accumulator_sum;
  assign valid_out = valid_out_s0 & ~valid_out_s2;

endmodule
