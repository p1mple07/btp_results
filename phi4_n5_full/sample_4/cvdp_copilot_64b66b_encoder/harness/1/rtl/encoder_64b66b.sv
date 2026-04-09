module encoder_64b66b (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic [63:0]  encoder_data_in,
    input  logic [7:0]   encoder_control_in,
    output logic [65:0]  encoder_data_out
);

  // On reset, output is zero.
  // On each clock cycle, if control word is pure data (8'b00000000),
  // output = {2'b01, data}; otherwise, output = {2'b10, 64'd0}.
  always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
      encoder_data_out <= 66'd0;
    end else begin
      if (encoder_control_in == 8'b00000000)
        encoder_data_out <= {2'b01, encoder_data_in};
      else
        encoder_data_out <= {2'b10, 64'd0};
    end
  end

endmodule