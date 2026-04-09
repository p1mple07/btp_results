module spi_complex_mult (
  // Inputs
  input wire rst_n,
  input wire spi_clk,
  input wire spi_cs_n,
  input wire [15:0] spi_data_in,
  input wire spi_write_en,
  
  // Outputs
  output reg spi_data_out,
  output reg spi_valid_out
);

  reg [15:0] data_reg;
  reg [15:0] result;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data_reg <= 16'b0;
      result <= 16'b0;
      spi_valid_out <= 1'b0;
    end else begin
      if (spi_write_en) begin
        data_reg <= spi_data_in;
        spi_valid_out <= 1'b1;
      end else begin
        result <= data_reg * spi_data_in;
        spi_data_out <= result[15:8];
        spi_valid_out <= 1'b1;
      end
    end
  end

endmodule