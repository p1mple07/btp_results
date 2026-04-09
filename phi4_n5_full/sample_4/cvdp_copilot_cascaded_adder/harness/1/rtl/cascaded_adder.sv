module cascaded_adder #(
  parameter IN_DATA_WIDTH = 16,
  parameter IN_DATA_NS    = 4
)(
  input  logic         clk,
  input  logic         rst_n,
  input  logic         i_valid,
  input  logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] i_data,
  output logic         o_valid,
  output logic [IN_DATA_WIDTH + $clog2(IN_DATA_NS) - 1:0] o_data
);

  //-------------------------------------------------------------------------
  // Internal register to latch input data on valid assertion.
  //-------------------------------------------------------------------------
  logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] r_data;

  //-------------------------------------------------------------------------
  // Internal register to hold the computed cumulative sum.
  // The width is chosen to accommodate the full sum without overflow.
  //-------------------------------------------------------------------------
  logic [IN_DATA_WIDTH + $clog2(IN_DATA_NS) - 1:0] r_sum;

  //-------------------------------------------------------------------------
  // Latch the flattened input data when i_valid is asserted.
  // One cycle latency.
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      r_data <= '0;
    end
    else if (i_valid) begin
      r_data <= i_data;
    end
  end

  //-------------------------------------------------------------------------
  // Cascaded addition: Sum each element in sequence.
  // The sum is computed in combinational logic from the registered data.
  //-------------------------------------------------------------------------
  integer i;
  logic [IN_DATA_WIDTH + $clog2(IN_DATA_NS) - 1:0] sum;
  always_comb begin
    sum = '0;
    for (i = 0; i < IN_DATA_NS; i = i + 1) begin
      sum = sum + r_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH];
    end
  end

  //-------------------------------------------------------------------------
  // Register the computed sum into r_sum.
  // This adds one more cycle of latency.
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      r_sum <= '0;
    else
      r_sum <= sum;
  end

  //-------------------------------------------------------------------------
  // Drive the output valid signal.
  // o_valid is asserted on the clock edge when the cumulative sum is ready.
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      o_valid <= 1'b0;
    else if (i_valid)
      o_valid <= 1'b1;
    else
      o_valid <= 1'b0;
  end

  //-------------------------------------------------------------------------
  // Drive the output data with the registered cumulative sum.
  //-------------------------------------------------------------------------
  assign o_data = r_sum;

endmodule