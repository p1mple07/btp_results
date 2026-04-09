module data_width_converter(
  input  wire logic clk,
  input  wire logic reset,
  input  wire [31:0] data_in,
  input  wire logic data_valid,
  output      logic o_data_out_valid,
  output reg [127:0] o_data_out
);

  // Define registers and signals
  reg [31:0] data_reg [3:0];
  reg [2:0] counter;
  reg valid_reg;

  // Concatenate four 32-bit inputs into a single 128-bit output
  always @(posedge clk) begin
    if (reset) begin
      data_reg <= 4'h0;
      counter <= 0;
      valid_reg <= 0;
    end else if (counter < 4 && data_valid) begin
      data_reg[counter] <= data_in;
      counter <= counter + 1;
    end else if (counter == 4) begin
      o_data_out <= {data_reg[3], data_reg[2], data_reg[1], data_reg[0]};
      o_data_out_valid <= valid_reg;
      valid_reg <= 0;
      counter <= 0;
    end else if (counter > 4) begin
      valid_reg <= 0;
      counter <= 0;
    end
  end

endmodule