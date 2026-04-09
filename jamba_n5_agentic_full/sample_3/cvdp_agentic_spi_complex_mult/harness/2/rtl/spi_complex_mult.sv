module spi_complex_mult (
    input rst_async_n,
    input spi_sck,
    input spi_cs_n,
    input spi_mosi,
    output reg [31:0] real_result,
    output reg [31:0] imag_result
);

reg [3:0] count;
reg [3:0] addr;
reg ready;

always @(posedge spi_sck) begin
    if (!rst_async_n) begin
        count <= 0;
        ready <= 0;
    end else begin
        count <= count + 1;
        if (count == 1) begin
            // Start of SPI transaction: CS low
            spi_cs_n <= 0;
        end
    end
end

always @(data or negated_clock) begin
    if (~spi_cs_n && spi_mosi != 0) begin
        // Master sends data
        real_result <= mosi_in;
    end else if (spi_mosi != 0) begin
        // Master receives data
        imag_result <= mosi_in;
    end
end

// Wait, this is too simplistic.

endmodule
