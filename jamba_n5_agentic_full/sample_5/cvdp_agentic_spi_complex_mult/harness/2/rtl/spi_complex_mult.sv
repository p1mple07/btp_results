module spi_complex_mult (
    input rst_async_n,
    input spi_cs_n,
    input spi_mosi,
    output reg spi_miso,
    output [31:0] result_real,
    output [31:0] result_imag
);

parameter IN_WIDTH = 16, OUT_WIDTH = 32;

reg [31:0] temp_real;
reg [31:0] temp_imag;
reg [31:0] product_real;
reg [31:0] product_imag;

always @(posedge spi_sck) begin
    if (!rst_async_n) begin
        temp_real <= 0;
        temp_imag <= 0;
        product_real <= 0;
        product_imag <= 0;
    end else begin
        temp_real <= mosi;
        temp_imag <= miso;
        product_real = temp_real[31];
        product_imag = temp_imag[31];
    end
end

always @(*) begin
    result_real = temp_real;
    result_imag = temp_imag;
end

assign spi_miso = temp_imag;
assign spi_mosi = temp_real;

endmodule
