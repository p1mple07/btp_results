module pipeline_mac (#(DWIDTH=16, N=4));

  parameter DWIDTH = 16;
  parameter N      = 4;

  input logic clk;
  input logic rstn;
  input logic [DWIDTH-1:0] multiplicand;
  input logic [DWIDTH-1:0] multiplier;
  input logic valid_i;
  output logic [DWIDTH_ACCUMULATOR-1:0] result;
  output logic valid_out;

  // Internal registers and counters
  logic [DWIDTH_ACCUMULATOR-1:0] mult_result_reg;
  logic [DWIDTH_ACCUMULATOR-1:0] accumulation_reg;
  logic [$clog2(N):0] counter;
  logic [$clog2(N):0] acc_count;
  logic count_rst, accumulator_rst;
  logic valid_out_s0, valid_out_s1, valid_out_s2;
  logic valid_i_s1;

  // Counters and reset logic
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      counter <= 0;
      acc_count <= 0;
      mult_result_reg <= 0;
      accumulation_reg <= 0;
      result <= 0;
      valid_out <= 0;
      valid_out_s0 <= 0;
      valid_out_s1 <= 0;
      valid_out_s2 <= 0;
      valid_i_s1 <= 0;
    end else begin
      counter <= counter + 1;
      if (counter == N) begin
        // Output the final accumulated value
        always @(posedge clk) begin
          if (acc_count == 0) begin
            result <= accumulation_reg;
          end
        end
        counter <= 0;
        accumulation_reg <= 0;
        acc_count <= 0;
      end
    end
  end

  // Stage 1: Multiplication
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      mult_result_reg <= 0;
    end else begin
      mult_result_reg <= multiplicand * multiplier;
    end
  end

  // Stage 2: Accumulation
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      accumulation_reg <= 0;
    end else begin
      if (valid_i) begin
        accumulation_reg <= accumulation_reg + (mult_result_reg + accumulator_reg);
      end
    end
  end

  // Final output generation
  assign result = accumulation_reg;
  assign valid_out = valid_out_s1 & ~valid_out_s2;
endmodule
