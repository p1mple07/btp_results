module dbi_enc(
  input logic [39:0] data_in,
  input logic clk,
  input logic rst_n,
  output logic [39:0] data_out,
  output logic [1:0] dbi_cntrl
);

  // Splitting incoming data
  assign {group_1, group_0} = data_in;

  // Comparing with previous data
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      prev_data <= 40'h000000000000000;
    end else begin
      prev_data <= {prev_data[39:20], group_0};
    end
  end

  assign diff_1 = |(group_1 ^ prev_data[39:20]);
  assign diff_0 = |(group_0 ^ prev_data[19:0]);

  // Control signal behavior
  assign dbi_cntrl[1] = (diff_1 > 10)? 1'b1 : 1'b0;
  assign dbi_cntrl[0] = (diff_0 > 10)? 1'b1 : 1'b0;

  // Generating data_out
  assign data_out[39:20] = (dbi_cntrl[1])? ~group_1 : group_1;
  assign data_out[19:0] = (dbi_cntrl[0])? ~group_0 : group_0;

endmodule