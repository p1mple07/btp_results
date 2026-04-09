module continuous_adder(
    parameter integer DATA_WIDTH       = 32,
    parameter integer ENABLE_THRESHOLD = 0,
    parameter integer THRESHOLD        = 16,
    parameter integer REGISTER_OUTPUT  = 0
)

  output reg [DATA_WIDTH-1:0] sum_out,
         sum_valid;

  integer sum_reg [DATA_WIDTH-1:0] = 0;
  integer sum_valid_reg = 0;

  always @ posedge(clk) begin
    if (rst_n) begin
      sum_reg = 0;
      sum_valid_reg = 0;
    end else begin
      if (flush) begin
        sum_reg = 0;
        sum_valid_reg = 0;
      end else if (valid_in & accumulate_enable) begin
        sum_reg = sum_reg + data_in;
        sum_valid_reg = 1;
      end
    end
  end

  // Threshold handling
  if (ENABLE_THRESHOLD & sum_valid_reg) begin
    if (sum_reg >= THRESHOLD) begin
      sum_out = sum_reg;
      sum_valid = 1;
    else begin
      sum_out = sum_valid_reg;
      sum_valid = 0;
    end
  end

  // Registering output
  if (REGISTER_OUTPUT) begin
    sum_out = sum_reg;
    sum_valid = sum_valid_reg;
  end else begin
    sum_reg <= sum_reg + data_in;
    sum_valid_reg <= sum_valid_reg | ((sum_reg >= THRESHOLD) & sum_valid_reg);
  end

endmodule