// Module declaration
module spi_complex_mult(
    input wire [IN_WIDTH-1:0] rst_async_n,
    input wire [1:0] spi_sck,
    input wire [1:0] spi_cs_n,
    input wire [OUT_WIDTH-1:0] spi_mosi,
    output reg [OUT_WIDTH-1:0] spi_miso
);

// Internal variables
reg [OUT_WIDTH-1:0] real_part;
reg [OUT_WIDTH-1:0] imag_part;

// Constants for multiplication
constant [15:0] MULT_1 = 16 # 16; // Assuming 16-bit multiplier constants

// Multiply Ar * Br and Ar * Bi using DSP multipliers
mult_32-bit multiplier_1(.clock(spi_sck), .rst(rst_async_n), .a_in(Ar), .b_in(Tr), .result(real_part));
mult_32-bit multiplier_2(.clock(spi_sck), .rst(rst_async_n), .a_in(Ar), .b_in(Ti), .result(imag_part));

// Multiply Ai * Br and Ai * Bi using DSP multipliers
mult_32-bit multiplier_3(.clock(spi_sck), .rst(rst_async_n), .a_in(Ai), .b_in(Tr), .result(temp_real));
mult_32-bit multiplier_4(.clock(spi_sck), .rst(rst_async_n), .a_in(Ai), .b_in(Ti), .result(temp_imag));

// Subtract Ai * Bi from Ar * Br to get real part
add_32-bit adder(.clock(spi_sck), .rst(rst_async_n), .a_in(real_part), .b_in(temp_real), .sum(real_part));

// Add Ar * Bi and Ai * Br to get imaginary part
add_32-bit adder(.clock(spi_sck), .rst(rst_async_n), .a_in(temp_imag), .b_in(imag_part), .sum(imag_part));

// Output the results via SPI
spim mosi real_part;
spim mosi imag_part;

// Synchronize the output to meet SPI requirements
always_ff @(posedge spi_sck) begin
    spi_miso <= spi_mosi;
end

// Ensure proper timing closure by buffering the output
wire [OUT_WIDTH-1:0] buffer_real;
wire [OUT_WIDTH-1:0] buffer_imag;
always_ff @(negedge spi_sck) begin
    buffer_real <= real_part;
    buffer_imag <= imag_part;
end

spim mosi buffer_real;
spim mosi buffer_imag;

// Cleanup
always @(rst_async_n) begin
    real_part <= 0;
    imag_part <= 0;
    buffer_real <= 0;
    buffer_imag <= 0;
end

// Ensure proper propagation of the clean-up signal
wire clean_up;
always_ff '@(rst_async_n)' clean_up <= 1;

// Final synchronization
always @(posedge spi_sck || clean_up) begin
    spi_miso <= 0;
end