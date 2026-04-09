module spi_complex_mult #(
    parameter IN_WIDTH = 16,
    parameter OUT_WIDTH = 32
) (
    input rst_async_n,
    input spi_sck,
    input spi_cs_n,
    input spi_mosi,
    input spi_miso,
    output reg [31:0] out_data_real,
    output reg [31:0] out_data_imag,
    output reg out_complex,
    output reg out_real_valid,
    output reg out_imag_valid
);

// Internal registers for the complex data
reg [IN_WIDTH-1:0] ar;
reg [IN_WIDTH-1:0] ai;
reg [IN_WIDTH-1:0] br;
reg [IN_WIDTH-1:0] bi;
reg [OUT_WIDTH-1:0] out_real;
reg [OUT_WIDTH-1:0] out_imag;

// Enable flags for output validity
assign out_real_valid = out_real != 0;
assign out_imag_valid = out_imag != 0;

always @(posedge spi_sck) begin
    if (!rst_async_n) begin
        // Reset all internal signals
        ar <= 0;
        ai <= 0;
        br <= 0;
        bi <= 0;
        out_real <= 0;
        out_imag <= 0;
        out_complex <= 0;
        out_real_valid <= 0;
        out_imag_valid <= 0;
    end else begin
        // Read the incoming data on SPI
        ar = spi_mosi;
        ai = spi_miso;
        br = spi_mosi;
        bi = spi_miso;

        // Perform the complex multiplication
        out_real = ar * br - ai * bi;
        out_imag = ar * bi + ai * br;

        // Set the output validity signals
        out_complex = out_real == 0 && out_imag == 0;
        out_real_valid = out_real != 0;
        out_imag_valid = out_imag != 0;
    end
end

endmodule
