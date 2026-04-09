modules
include "rtl/arithunit.sv"

// Module definition
module spi_complex_mult (
    // Pins
    rst_async_n,
    spi_sck,
    spi_cs_n,
    spi_mosi,
    spi_miso
);

    // Internal registers
    reg [15:0] ar, ai, br, bi; // Input values (8-bit each)
    reg [31:0] real_part, imag_part; // Results (16-bit each)
    
    // Constants for multiplication
    const signed [15:0] ONE = 1;
    const signed [15:0] TWO = 2;

    // Instantiate arithmetic unit
    SpiUnit multiplier1(.clk(spi_sck), .rst(nrst), .ain1(ar), .ain2(br), .obuf(mult1_real));
    SpiUnit multiplier2(.clk(spi_sck), .rst(nrst), .ain1(ai), .ain2(bi), .obuf(mult1_imag));
    SpiUnit adder1(.clk(spi_sck), .rst(nrst), .ain1(mult1_real), .ain2(mult1_imag), .obuf(imag_part));
    SpiUnit subtr(.clk(spi_sck), .rst(nrst), .ain1(mult1_real), .ain2(mult1_imag), .obuf(real_part));

    // Control signals
    wire rst_init = !rst_async_n;

    // Initializations
    initial begin
        $stick rst_async_n #10 () "init";
        $stick spi_sck #10 () "start";
    end

    // Event listeners
    event [rst_init#1] rst_event;
    event [spider#1] spider_event;

    // Event handling
    always @(rst_event or spider_event) begin
        // Handle initialization
        if (!rst_event || !spider_event) begin
            // Initialize input values
            ar <= 0;
            ai <= 0;
            br <= 0;
            bi <= 0;
        end
    end

    // Data transfer events
    event [real_part#1, imag_part#1] data_event;

    // Processing pipeline
    always @posedge spi_sck begin
        // Receive input values
        ar <= spi_mosi;
        ai <= spi_miso;
        br <= spi_mosi;
        bi <= spi_miso;
        
        // Compute real part = ar*br - ai*bi
        mult1_real = ar * br;
        mult1_imag = ai * bi;
        
        // Compute imaginary part = ar*bi + ai*br
        imag_part = (ar * bi) + (ai * br);
        real_part = (mult1_real) - (mult1_imag);
        
        // Send results
        spi_miso <= real_part;
        spi_miso <= imag_part;
    end

endmodule