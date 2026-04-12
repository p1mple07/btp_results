`timescale 1ns / 1ps

module csr_apb_interface_tb;

// Testbench Signals
reg                       tb_pclk;       // Clock signal for the UUT
reg                       tb_presetn;    // Active low reset signal
reg [31:0]                tb_paddr;      // Address bus (hardcoded to 32 bits for this design)
reg                       tb_pselx;      // Peripheral select signal
reg                       tb_penable;    // Enable signal for APB transaction
reg                       tb_pwrite;     // Write enable signal (1 for write, 0 for read)
reg [31:0]                tb_pwdata;     // Data bus for write operations (32 bits)
wire                      tb_pready;     // Ready signal from the UUT
wire [31:0]               tb_prdata;     // Data bus for read operations from the UUT
wire                      tb_pslverr;    // Slave error signal from the UUT

// Define register addresses using parameters for flexibility
localparam DATA_REG       = 32'h10;      // Data register address
localparam CONTROL_REG    = 32'h14;      // Control register address
localparam INTERRUPT_REG  = 32'h18;      // Interrupt configuration register address

// Instantiate the Unit Under Test (UUT)
csr_apb_interface uut (
    .pclk(tb_pclk),
    .presetn(tb_presetn),
    .paddr(tb_paddr),
    .pselx(tb_pselx),
    .penable(tb_penable),
    .pwrite(tb_pwrite),
    .pwdata(tb_pwdata),
    .pready(tb_pready),
    .prdata(tb_prdata),
    .pslverr(tb_pslverr)
);

always #5 tb_pclk = ~tb_pclk; 

initial begin
    // Initialize signals to default values
    tb_pclk = 0;
    tb_presetn = 1;
    tb_paddr = 0;
    tb_pselx = 0;
    tb_penable = 0;
    tb_pwrite = 0;
    tb_pwdata = 0;
    
    // Apply reset
    @(negedge tb_pclk);
    tb_presetn = 0; 
    @(negedge tb_pclk);
    tb_presetn = 1; 
    repeat (2) @(posedge tb_pclk); 

    // Start of test cases
    // Test Writing to DATA_REG
    tb_pselx = 1;
    tb_pwrite = 1;
    tb_pwdata = $urandom; // Generate a full 32-bit random data
    tb_paddr = DATA_REG;
    @(posedge tb_pclk);
    tb_penable = 1;
    @(posedge tb_pclk);
    tb_penable = 0;
    tb_pselx = 0;
    repeat (2) @(posedge tb_pclk); 

    // Test Reading from DATA_REG
    tb_pselx = 1;
    tb_pwrite = 0; 
    tb_paddr = DATA_REG;
    @(posedge tb_pclk);
    tb_penable = 1;
    @(posedge tb_pclk);
    tb_penable = 0;
    tb_pselx = 0;
    repeat (2) @(posedge tb_pclk);

    if (tb_prdata == tb_pwdata)
        $display("TEST PASSED: DATA_REG read/write successful.");
    else
        $display("TEST FAILED: DATA_REG read/write mismatch.");

    // Writing and reading back from CONTROL_REG
    tb_pselx = 1;
    tb_pwrite = 1;
    tb_pwdata = $urandom; 
    tb_paddr = CONTROL_REG;
    @(posedge tb_pclk);
    tb_penable = 1;
    @(posedge tb_pclk);
    tb_penable = 0;
    tb_pselx = 0;
    repeat (2) @(posedge tb_pclk);

    tb_pselx = 1;
    tb_pwrite = 0;
    tb_paddr = CONTROL_REG;
    @(posedge tb_pclk);
    tb_penable = 1;
    @(posedge tb_pclk);
    tb_penable = 0;
    tb_pselx = 0;
    repeat (2) @(posedge tb_pclk);

    // Validate the read data
    if (tb_prdata == tb_pwdata)
        $display("TEST PASSED: CONTROL_REG read/write successful.");
    else
        $display("TEST FAILED: CONTROL_REG read/write mismatch.");

    // Writing and reading back from INTERRUPT_REG
    tb_pselx = 1;
    tb_pwrite = 1;
    tb_pwdata = $urandom;
    tb_paddr = INTERRUPT_REG;
    @(posedge tb_pclk);
    tb_penable = 1;
    @(posedge tb_pclk);
    tb_penable = 0;
    tb_pselx = 0;
    repeat (2) @(posedge tb_pclk);

    // Reading from INTERRUPT_REG
    tb_pselx = 1;
    tb_pwrite = 0;
    tb_paddr = INTERRUPT_REG;
    @(posedge tb_pclk);
    tb_penable = 1;
    @(posedge tb_pclk);
    tb_penable = 0;
    tb_pselx = 0;
    repeat (2) @(posedge tb_pclk);

    // Validate the read data
    if (tb_prdata == tb_pwdata)
        $display("TEST PASSED: INTERRUPT_REG read/write successful.");
    else
        $display("TEST FAILED: INTERRUPT_REG read/write mismatch.");

    // End simulation
    $finish;
end

initial begin
    $dumpfile("test.vcd");                  // Specify the VCD file for waveform dumping
    $dumpvars(0, csr_apb_interface_tb);     // Dump all variables in the testbench
  end 

endmodule
