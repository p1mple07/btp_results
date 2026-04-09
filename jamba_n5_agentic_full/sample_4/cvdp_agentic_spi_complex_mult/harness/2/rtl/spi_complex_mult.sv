module spi_complex_mult (
    input rst_async_n,
    input spi_sck,
    input spi_cs_n,
    input spi_mosi,
    output reg [31:0] spi_miso
);

    localparam IN_WIDTH = 16;
    localparam OUT_WIDTH = 32;

    reg [31:0] data;
    reg [7:0] temp;

    always @(posedge spi_sck) begin
        if (!rst_async_n) begin
            data <= 0;
        end else begin
            case (spi_mosi)
                4'b0000: begin
                    // receive data on mosi
                    data = spi_mosi;
                end
                4'b0001: begin
                    // do nothing
                end
                4'b0010: begin
                    // start multiplication
                    temp = data * 2;
                end
                4'b0011: begin
                    // read data on miso
                    data = spi_miso;
                end
                4'b0100: begin
                    // start transmission
                    spi_mosi = data;
                end
                4'b0101: begin
                    // something else
                end
                4'b0110: begin
                    // etc.
                end
                4'b0111: begin
                    // etc.
                end
                default: // ignore
            endcase
        end
    end

    assign spi_miso = data;

endmodule
