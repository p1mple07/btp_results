module cascaded_adder #(
  parameter IN_DATA_WIDTH = 16,
  parameter IN_DATA_NS    = 4
) (
  input  logic             clk,
  input  logic             rst_n,
  input  logic             i_valid,
  input  logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] i_data,
  output logic             o_valid,
  output logic [IN_DATA_WIDTH + $clog2(IN_DATA_NS)-1:0] o_data
);

  // Define the width required for the cumulative sum.
  localparam SUM_WIDTH = IN_DATA_WIDTH + $clog2(IN_DATA_NS);

  // Pipeline register to latch the input data.
  logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] data_reg;
  // Pipeline register to capture the input valid signal.
  logic valid_reg;
  // Pipeline register to latch the computed sum.
  logic [SUM_WIDTH-1:0] sum_reg;

  // Combinational logic to perform cascaded addition on the registered input data.
  // The input vector is divided into IN_DATA_NS elements, each of width IN_DATA_WIDTH.
  always_comb begin
    logic [SUM_WIDTH-1:0] sum;
    sum = '0;
    for (int i = 0; i < IN_DATA_NS; i++) begin
      // Extract the i-th element from data_reg.
      // The slice [ (i+1)*IN_DATA_WIDTH-1 : i*IN_DATA_WIDTH ] represents one data element.
      sum = sum + data_reg[((i+1)*IN_DATA_WIDTH)-1 -: IN_DATA_WIDTH];
    end
  end

  // Pipeline Stage 1: Register the input data and valid signal.
  // When i_valid is asserted, data_reg is updated with i_data.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data_reg  <= '0;
      valid_reg <= 1'b0;
    end else begin
      if (i_valid)
        data_reg <= i_data;
      valid_reg <= i_valid;
    end
  end

  // Pipeline Stage 2: Register the computed sum and valid signal.
  // The sum is computed from the previously registered data (data_reg from the previous cycle).
  // This stage introduces a one-cycle delay relative to Stage 1.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sum_reg  <= '0;
      o_valid  <= 1'b0;
      o_data   <= '0;
    end else begin
      sum_reg  <= sum;      // sum computed from data_reg (from previous cycle)
      o_valid  <= valid_reg; // valid signal delayed by two cycles overall
      o_data   <= sum_reg;
    end
  end

endmodule