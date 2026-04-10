`timescale 1ns/1ps

module cvdp_copilot_apb_gpio_tb;

  // Parameters
  parameter GPIO_WIDTH = 8;

  // Clock and Reset Signals
  reg pclk;               // Clock signal
  reg preset_n;           // Active-low reset signal

  // APB Interface Signals
  reg psel;               // Peripheral select signal
  reg [7:2] paddr;        // APB address bus
  reg penable;            // Transfer control signal
  reg pwrite;             // Write control signal
  reg [31:0] pwdata;      // Write data bus
  wire [31:0] prdata;     // Read data bus
  wire pready;            // Device ready signal
  wire pslverr;           // Device error signal

  // Bidirectional GPIO Interface Signals
  wire [GPIO_WIDTH-1:0] gpio; // Bidirectional GPIO pins

  // Internal Variables for GPIO Simulation
  logic [GPIO_WIDTH-1:0] gpio_drive;    // Signals driven onto GPIO pins by the testbench
  logic [GPIO_WIDTH-1:0] gpio_drive_en; // Enable signals for driving GPIOs
  wire [GPIO_WIDTH-1:0] gpio_in_tb;     // Signals read from GPIO pins by the testbench

  // Interrupt Signals
  wire [GPIO_WIDTH-1:0] gpio_int; // Individual interrupt outputs
  wire comb_int;                  // Combined interrupt output

  // Internal Variables
  integer i;
  reg [31:0] read_data; // For storing read data
  reg test_passed;      // Flag to indicate test pass/fail

  // Instantiate the DUT (Device Under Test)
  cvdp_copilot_apb_gpio #(
    .GPIO_WIDTH(GPIO_WIDTH)
  ) dut (
    .pclk(pclk),
    .preset_n(preset_n),
    .psel(psel),
    .paddr(paddr),
    .penable(penable),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready),
    .pslverr(pslverr),
    .gpio(gpio),
    .gpio_int(gpio_int),
    .comb_int(comb_int)
  );

  // Modeling Bidirectional GPIOs
  // Assigning 'z' when testbench is not driving the GPIO pins
  genvar idx;
  generate
    for (idx = 0; idx < GPIO_WIDTH; idx = idx + 1) begin : gpio_model
      assign gpio[idx] = (gpio_drive_en[idx]) ? gpio_drive[idx] : 1'bz;
      assign gpio_in_tb[idx] = gpio[idx];
    end
  endgenerate

  // Clock Generation: 50 MHz Clock (Period = 20 ns)
  initial begin
    pclk = 0;
    forever #10 pclk = ~pclk;
  end

  // Reset Generation
  initial begin
    preset_n = 0;
    #50; // Hold reset low for 50 ns
    preset_n = 1;
  end

  // VCD Dump for Waveform Viewing
  initial begin
    $dumpfile("cvdp_copilot_apb_gpio_tb.vcd");
    $dumpvars(0, cvdp_copilot_apb_gpio_tb);
  end

  // APB Read Task
  task apb_read;
    input [7:2] address;
    output [31:0] data;
    begin
      @ (posedge pclk);
      psel = 1;
      paddr = address;
      pwrite = 0;
      penable = 0;
      @ (posedge pclk);
      penable = 1;
      @ (posedge pclk);
      data = prdata; // Capture data after access phase
      psel = 0;
      penable = 0;
    end
  endtask

  // APB Write Task
  task apb_write;
    input [7:2] address;
    input [31:0] data;
    begin
      @ (posedge pclk);
      psel = 1;
      paddr = address;
      pwrite = 1;
      pwdata = data;
      penable = 0;
      @ (posedge pclk);
      penable = 1;
      @ (posedge pclk);
      psel = 0;
      penable = 0;
    end
  endtask

  // Test Sequence
  initial begin
    // Initialize APB Signals
    psel = 0;
    paddr = 0;
    penable = 0;
    pwrite = 0;
    pwdata = 0;

    // Initialize GPIO Drive Signals
    gpio_drive = {GPIO_WIDTH{1'b0}};
    gpio_drive_en = {GPIO_WIDTH{1'b0}};

    // Wait for Reset Deassertion
    wait(preset_n == 1);

    // Wait for a few clock cycles
    repeat (5) @ (posedge pclk);

    // Test 1: Bidirectional GPIOs - Configure Directions and Verify I/O
    $display("\nTest 1: Bidirectional GPIOs - Direction Control");
    // Configure GPIO[7:4] as outputs, GPIO[3:0] as inputs
    apb_write(6'd7, 32'hF0); // Write to Direction Control Register at 0x1C
    apb_read(6'd7, read_data);
    if (read_data[GPIO_WIDTH-1:0] !== 8'hF0) begin
      $display("FAIL: Direction Control Register mismatch");
    end else begin
      $display("PASS: Direction Control Register set to 0x%0h", read_data[GPIO_WIDTH-1:0]);
    end

    // Write data to outputs
    apb_write(6'd1, 32'hA0); // Data Output Register at 0x04
    apb_read(6'd1, read_data);
    if (read_data[GPIO_WIDTH-1:0] !== 8'hA0) begin
      $display("FAIL: Data Output Register mismatch");
    end else begin
      $display("PASS: Data Output Register value: 0x%0h", read_data[GPIO_WIDTH-1:0]);
    end

    // Verify that GPIO[7:4] are driven by the DUT
    #20; // Wait for GPIO outputs to settle
    for (i = 4; i < 8; i = i + 1) begin
      if (gpio[i] !== ((8'hA0 >> i) & 1'b1)) begin
        $display("FAIL: GPIO[%0d] output mismatch. Expected: %b, Got: %b", i, ((8'hA0 >> i) & 1'b1), gpio[i]);
      end else begin
        $display("PASS: GPIO[%0d] output matches expected value", i);
      end
    end

    // Drive values on GPIO[3:0] and verify input data
    gpio_drive[3:0] = 4'hB;      // Drive 0b1011 on GPIO[3:0]
    gpio_drive_en[3:0] = 4'hF;    // Enable driving on GPIO[3:0]
    repeat (3) @ (posedge pclk); // Wait for synchronization
    apb_read(6'd0, read_data); // Read Input Data Register at 0x00
    if (read_data[3:0] !== 4'hB) begin
      $display("FAIL: GPIO Input Data mismatch on GPIO[3:0]");
    end else begin
      $display("PASS: GPIO Input Data on GPIO[3:0] is 0x%0h", read_data[3:0]);
    end
    gpio_drive_en[3:0] = 4'h0; // Stop driving GPIO[3:0]

    // Test 2: Power Management - Power Down and Power Up
    $display("\nTest 2: Power Management - Power Down and Power Up");
    // Power down the module
    apb_write(6'd8, 32'h1); // Write to Power Down Register at 0x20
    #20; // Wait for module to power down

    // Attempt to change outputs while powered down
    apb_write(6'd1, 32'hFF); // Try to write to Data Output Register
    apb_read(6'd1, read_data);
    if (read_data[GPIO_WIDTH-1:0] !== 8'hA0) begin
      $display("FAIL: Data Output Register changed during power-down");
    end else begin
      $display("PASS: Data Output Register did not change during power-down");
    end

    // Check that GPIO outputs are tri-stated
    #20; // Wait for GPIO outputs to settle
    for (i = 4; i < 8; i = i + 1) begin
      if (gpio[i] !== 1'bz) begin
        $display("FAIL: GPIO[%0d] should be tri-stated during power-down", i);
      end else begin
        $display("PASS: GPIO[%0d] is tri-stated during power-down", i);
      end
    end

    // Power up the module
    apb_write(6'd8, 32'h0); // Write to Power Down Register to power up
    #20; // Wait for module to power up

    // Verify that outputs return to previous state
    for (i = 4; i < 8; i = i + 1) begin
      if (gpio[i] !== ((8'hA0 >> i) & 1'b1)) begin
        $display("FAIL: GPIO[%0d] output mismatch after power-up. Expected: %b, Got: %b", i, ((8'hA0 >> i) & 1'b1), gpio[i]);
      end else begin
        $display("PASS: GPIO[%0d] output restored after power-up", i);
      end
    end

    // Test 3: Software-Controlled Reset for Interrupts
    $display("\nTest 3: Software-Controlled Reset for Interrupts");
    // Configure GPIO[0] for edge-triggered interrupt
    apb_write(6'd4, 32'h01); // Interrupt Type Register at 0x10 (edge-triggered on GPIO[0])
    apb_write(6'd5, 32'h00); // Interrupt Polarity Register at 0x14 (active high)
    apb_write(6'd3, 32'h01); // Interrupt Enable Register at 0x0C (enable GPIO[0] interrupt)
    apb_write(6'd6, 32'hFF); // Clear any pending interrupts

    // Generate an edge on GPIO[0]
    gpio_drive[0] = 1'b0;
    gpio_drive_en[0] = 1'b1; // Enable driving GPIO[0]
    repeat (3) @ (posedge pclk);
    gpio_drive[0] = 1'b1;
    repeat (3) @ (posedge pclk); // Wait for edge detection

    // Check that interrupt is set
    apb_read(6'd6, read_data); // Interrupt State Register at 0x18
    if (read_data[0] !== 1'b1) begin
      $display("FAIL: Interrupt not set on GPIO[0]");
    end else begin
      $display("PASS: Interrupt set on GPIO[0]");
    end

    // Use software-controlled reset to clear interrupts
    apb_write(6'd9, 32'h1); // Write to Interrupt Control Register at 0x24
    #20; // Wait for interrupt reset

    // Verify that interrupt is cleared
    apb_read(6'd6, read_data);
    if (read_data[0] !== 1'b0) begin
      $display("FAIL: Interrupt not cleared by software-controlled reset");
    end else begin
      $display("PASS: Interrupt cleared by software-controlled reset");
    end

    // Disable GPIO[0] driving
    gpio_drive_en[0] = 1'b0;

    // Test 4: Combined Test - Changing Directions and Verifying Behavior
    $display("\nTest 4: Combined Test - Changing Directions and Verifying Behavior");
    // Change direction of GPIO[2] from input to output
    apb_write(6'd7, 32'hF4); // Update Direction Control Register (GPIO[2] as output)
    #20;

    // Write to Data Output Register
    apb_write(6'd1, 32'h04); // Set GPIO[2] high
    #20;

    // Verify that GPIO[2] is driven high
    if (gpio[2] !== 1'b1) begin
      $display("FAIL: GPIO[2] output mismatch after changing direction");
    end else begin
      $display("PASS: GPIO[2] output is high after changing direction to output");
    end

    // Change direction of GPIO[7] from output to input
    apb_write(6'd7, 32'h74); // Update Direction Control Register (GPIO[7] as input)
    #20;

    // Drive GPIO[7] from testbench
    gpio_drive[7] = 1'b1;
    gpio_drive_en[7] = 1'b1;
    repeat (3) @ (posedge pclk); // Wait for synchronization

    // Read Input Data Register
    apb_read(6'd0, read_data);
    if (read_data[7] !== 1'b1) begin
      $display("FAIL: GPIO[7] input data mismatch after changing direction");
    end else begin
      $display("PASS: GPIO[7] input data is high after changing direction to input");
    end

    // Disable GPIO[7] driving
    gpio_drive_en[7] = 1'b0;

    // Test 5: Verify Module Does Not Respond When Powered Down
    $display("\nTest 5: Verify Module Does Not Respond When Powered Down");
    // Power down the module
    apb_write(6'd8, 32'h1); // Power Down Register at 0x20
    #20;

    // Try to write to Direction Control Register while powered down
    apb_write(6'd7, 32'hFF); // Attempt to set all GPIOs as outputs
    #20;
    apb_read(6'd7, read_data);
    if (read_data[GPIO_WIDTH-1:0] !== 8'h74) begin
      $display("FAIL: Direction Control Register changed during power-down");
    end else begin
      $display("PASS: Direction Control Register did not change during power-down");
    end

    // Power up the module
    apb_write(6'd8, 32'h0); // Power Down Register at 0x20
    #20;

    // Verify that module responds again
    apb_write(6'd7, 32'hFF); // Set all GPIOs as outputs
    apb_read(6'd7, read_data);
    if (read_data[GPIO_WIDTH-1:0] !== 8'hFF) begin
      $display("FAIL: Module did not respond after power-up");
    end else begin
      $display("PASS: Module responds correctly after power-up");
    end

    // Test 6: Verify Interrupts Do Not Occur When Powered Down
    $display("\nTest 6: Verify Interrupts Do Not Occur When Powered Down");
    // Configure interrupts on GPIO[1]
    apb_write(6'd4, 32'h02); // Interrupt Type Register (edge-triggered on GPIO[1])
    apb_write(6'd5, 32'h00); // Interrupt Polarity Register (active high)
    apb_write(6'd3, 32'h02); // Interrupt Enable Register (enable GPIO[1] interrupt)
    apb_write(6'd6, 32'hFF); // Clear any pending interrupts

    // Power down the module
    apb_write(6'd8, 32'h1); // Power Down Register at 0x20
    #20;

    // Generate an edge on GPIO[1]
    gpio_drive[1] = 1'b0;
    gpio_drive_en[1] = 1'b1;
    repeat (3) @ (posedge pclk);
    gpio_drive[1] = 1'b1;
    repeat (3) @ (posedge pclk);

    // Verify that no interrupt is set
    apb_read(6'd6, read_data);
    if (read_data[1] !== 1'b0) begin
      $display("FAIL: Interrupt occurred during power-down");
    end else begin
      $display("PASS: No interrupt occurred during power-down");
    end

    // Power up the module
    apb_write(6'd8, 32'h0); // Power Down Register at 0x20
    repeat (3) @ (posedge pclk);

    // Generate edge again
    gpio_drive[1] = 1'b0;
    repeat (3) @ (posedge pclk);
    gpio_drive[1] = 1'b1;
    repeat (3) @ (posedge pclk);

    // Verify that interrupt is now set
    apb_read(6'd6, read_data);
    if (read_data[1] !== 1'b1) begin
      $display("FAIL: Interrupt not set after power-up");
    end else begin
      $display("PASS: Interrupt set after power-up");
    end

    // Disable GPIO[1] driving
    gpio_drive_en[1] = 1'b0;

    // End of Testbench
    $display("\nTestbench completed successfully");
    $finish;
  end

endmodule