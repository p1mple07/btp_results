module spi_complex_mult (
  input wire rst_async_n,
  input wire spi_sck,
  input wire spi_cs_n,
  input wire [15:0] spi_mosi,
  output wire [15:0] spi_miso
);

  // Internal signals
  reg [15:0] ar;
  reg [15:0] ai;
  reg [15:0] br;
  reg [15:0] bi;
  reg [31:0] result;
  reg [3:0] clk_counter;

  // Register assignments
  always @(posedge spi_clk or negedge rst_async_n) begin
    if (!rst_async_n) begin
      ar <= 0;
      ai <= 0;
      br <= 0;
      bi <= 0;
      clk_counter <= 0;
    end else begin
      case (spi_mode)
        0: begin
          if (spi_sck == 0 && spi_cs_n == 0) begin
            ar <= spi_mosi;
            clk_counter <= clk_counter + 1;
          end
          if (clk_counter == 3) begin
            clk_counter <= 0;
            result <= ar * br;
          end
        end
        1: begin
          if (spi_sck == 0 && spi_cs_n == 0) begin
            ai <= spi_mosi;
            clk_counter <= clk_counter + 1;
          end
          if (clk_counter == 7) begin
            clk_counter <= 0;
            result <= result + ai * br;
          end
        end
        2: begin
          if (spi_sck == 0 && spi_cs_n == 0) begin
            br <= spi_mosi;
            clk_counter <= clk_counter + 1;
          end
          if (clk_counter == 11) begin
            clk_counter <= 0;
            result <= result + ar * bi;
          end
        end
        3: begin
          if (spi_sck == 0 && spi_cs_n == 0) begin
            bi <= spi_mosi;
            clk_counter <= clk_counter + 1;
          end
          if (clk_counter == 15) begin
            clk_counter <= 0;
            result <= result + ai * bi;
          end
        end
      endcase
      spi_miso <= {result[15:8], result[7:0]};
    end
  end

endmodule