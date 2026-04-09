Module for SPI Complex Multiply implementation
module spi_complex_mult (
    parameter IN_WIDTH = 16,
    parameter OUT_WIDTH = 32
);

    // Inputs
    input wire [IN_WIDTH-1:0] rst_async_n;  // Active low asynchronous reset
    input wire [IN_WIDTH-1:0] spi_sck;
    input wire [IN_WIDTH-1:0] spi_cs_n;   // Chip Select (active-low)
    input wire [IN_WIDTH-1:0] ar;         // Real part A (Ar)
    input wire [IN_WIDTH-1:0] ai;         // Imaginary part A (Ai)
    input wire [IN_WIDTH-1:0] br;         // Real part B (Br)
    input wire [IN_WIDTH-1:0] bi;         // Imaginary part B (Bi)

    // Outputs
    output wire [OUT_WIDTH-1:0] mosi;     // Master Out, Slave In
    output wire [OUT_WIDTH-1:0] miso;     // Master In, Slave Out
    output wire valid_out;                // Validity of output
    output wire rst_out;                 // Reset output (logical OR of inputs)

    // Internal registers and processing
    reg [IN_WIDTH+IN_WIDTH+IN_WIDTH*2-1:0] result_real, result_imag; // Results storage
    reg [IN_WIDTH+IN_WIDTH+IN_WIDTH*2-1:0] fifo_real, fifo_imag;       // FIFO buffer for output

    // Initialization
    always begin
        rst_async_n <= 1;
        // Wait until clock is stable before proceeding
        while (spike_init() != 0);
    end

    // Complex multiplication logic
    always @(posedge spi_sck) begin
        // Calculate real part: (Ar * Br) - (Ai * Bi)
        result_real = (ar[15:0] << (IN_WIDTH+1)) & ((br[15:0] << (IN_WIDTH+1)) - 
                                                  (ai[15:0] << (IN_WIDTH+1)) & bi[15:0]);

        // Calculate imaginary part: (Ar * Bi) + (Ai * Br)
        result_imag = (ar[15:0] << (IN_WIDTH+1)) & ((bi[15:0] << (IN_WIDTH+1)) +
                                                 (ai[15:0] << (IN_WIDTH+1)) & br[15:0]);
    end

    // Store results in FIFO buffer
    fifo_real <= result_real;
    fifo_imag <= result_imag;

    // Output generation
    always @* begin
        if (fifo_real != 0 || fifo_imag != 0) begin
            valid_out = 1;
        end
        // Send real part on MOSI
        mosi = fifo_real;
        // Send imaginary part on MISO after clock enable
        rst_out = rst_async_n;
        #1
        miso = fifo_imag;
        #1
        rst_out = ~rst_async_n;
    end

    // Assertions
    assert_validout();
endmodule