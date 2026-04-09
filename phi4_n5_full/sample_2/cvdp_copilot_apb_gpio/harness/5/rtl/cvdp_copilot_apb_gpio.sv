module cvdp_copilot_apb_gpio #(
  parameter GPIO_WIDTH = 8
)(
  // Clock and Reset Signals
  input logic pclk,       // Clock signal
  input logic preset_n,   // Active-low reset signal

  // APB Interface Inputs
  input logic psel,           // Peripheral select
  input logic [7:2] paddr,    // APB address bus (bits [7:2])
  input logic penable,        // Transfer control signal
  input logic pwrite,         // Write control signal
  input logic [31:0] pwdata,  // Write data bus

  // Bidirectional GPIO Interface
  inout logic [GPIO_WIDTH-1:0] gpio,  // Bidirectional GPIO pins

  // APB Interface Outputs
  output logic [31:0] prdata, // Read data bus
  output logic pready,        // Device ready signal
  output logic pslverr,       // Device error response

  // Interrupt Outputs
  output logic [GPIO_WIDTH-1:0] gpio_int, // Individual interrupt outputs
  output logic comb_int                   // Combined interrupt output
);

  //-------------------------------------------------------------------------
  // Internal Signals and Registers
  //-------------------------------------------------------------------------
  // Read/Write Control Signals
  logic read_enable;                     // Read enable signal
  logic write_enable;                    // Write enable signal

  // Write Enable Signals for Specific Registers
  logic write_enable_reg_04;             // Address 0x04: Data Output Register
  logic write_enable_reg_08;             // Address 0x08: Output Enable Register
  logic write_enable_reg_0C;             // Address 0x0C: Interrupt Enable Register
  logic write_enable_reg_10;             // Address 0x10: Interrupt Type Register
  logic write_enable_reg_14;             // Address 0x14: Interrupt Polarity Register
  logic write_enable_reg_18;             // Address 0x18: Interrupt State Register
  logic write_enable_reg_1C;             // Address 0x1C: Direction Control Register
  logic write_enable_reg_20;             // Address 0x20: Power Management Register
  logic write_enable_reg_24;             // Address 0x24: Interrupt Reset Register

  // Control Registers
  logic [GPIO_WIDTH-1:0] reg_dout;       // Data Output Register (0x04)
  logic [GPIO_WIDTH-1:0] reg_dout_en;    // Output Enable Register (0x08)
  logic [GPIO_WIDTH-1:0] reg_int_en;     // Interrupt Enable Register (0x0C)
  logic [GPIO_WIDTH-1:0] reg_int_type;   // Interrupt Type Register (0x10)
  logic [GPIO_WIDTH-1:0] reg_int_pol;    // Interrupt Polarity Register (0x14)
  logic [GPIO_WIDTH-1:0] reg_int_state;  // Interrupt State Register (0x18)

  // New Control Registers
  logic [GPIO_WIDTH-1:0] reg_gpio_dir;   // Direction Control Register (0x1C)
  logic [31:0] reg_pm;                  // Power Management Register (0x20)
  logic [GPIO_WIDTH-1:0] reg_int_reset; // Interrupt Reset Register (0x24)

  // Bidirectional GPIO Internal Input
  logic [GPIO_WIDTH-1:0] gpio_in_internal;

  // I/O Signal Path and Interrupt Logic
  logic [GPIO_WIDTH-1:0] data_in_sync1;            // First stage of input synchronization
  logic [GPIO_WIDTH-1:0] data_in_sync2;            // Second stage of input synchronization
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted;     // Polarity-adjusted input data
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted_dly; // Delayed version of polarity-adjusted input data
  logic [GPIO_WIDTH-1:0] edge_detect;              // Edge detection signals
  logic [GPIO_WIDTH-1:0] raw_int;                  // Raw interrupt signals
  logic [GPIO_WIDTH-1:0] int_masked;               // Masked interrupt signals
  logic [GPIO_WIDTH-1:0] clear_interrupt;          // Clear interrupt signals

  //-------------------------------------------------------------------------
  // APB Control Assignments
  //-------------------------------------------------------------------------
  assign read_enable = psel & (~pwrite); // Read enable
  assign write_enable = psel & (~penable) & pwrite; // Write enable

  // Decode write enable signals for each register based on APB address
  assign write_enable_reg_04 = write_enable & (paddr[7:2] == 6'd1); // 0x04
  assign write_enable_reg_08 = write_enable & (paddr[7:2] == 6'd2); // 0x08
  assign write_enable_reg_0C = write_enable & (paddr[7:2] == 6'd3); // 0x0C
  assign write_enable_reg_10 = write_enable & (paddr[7:2] == 6'd4); // 0x10
  assign write_enable_reg_14 = write_enable & (paddr[7:2] == 6'd5); // 0x14
  assign write_enable_reg_18 = write_enable & (paddr[7:2] == 6'd6); // 0x18
  assign write_enable_reg_1C = write_enable & (paddr[7:2] == 8'd7); // 0x1C: Direction Control
  assign write_enable_reg_20 = write_enable & (paddr[7:2] == 8'd8); // 0x20: Power Management
  assign write_enable_reg_24 = write_enable & (paddr[7:2] == 8'd9); // 0x24: Interrupt Reset

  //-------------------------------------------------------------------------
  // Register Write Operations
  //-------------------------------------------------------------------------
  // Data Output Register (reg_dout) - Address 0x04
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_dout <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_04)
      reg_dout <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Output Enable Register (reg_dout_en) - Address 0x08
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_dout_en <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_08)
      reg_dout_en <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Interrupt Enable Register (reg_int_en) - Address 0x0C
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_en <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_0C)
      reg_int_en <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Interrupt Type Register (reg_int_type) - Address 0x10
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_type <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_10)
      reg_int_type <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Interrupt Polarity Register (reg_int_pol) - Address 0x14
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_pol <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_14)
      reg_int_pol <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Interrupt State Register (reg_int_state) - Address 0x18
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      reg_int_state <= {GPIO_WIDTH{1'b0}};
    end else begin
      integer i;
      for (i = 0; i < GPIO_WIDTH; i = i + 1) begin
        if (reg_int_type[i]) begin
          // Edge-triggered interrupt
          if (clear_interrupt[i])
            reg_int_state[i] <= 1'b0;
          else if (int_masked[i])
            reg_int_state[i] <= 1'b1;
          // else retain previous state
        end else begin
          // Level-triggered interrupt
          reg_int_state[i] <= int_masked[i];
        end
      end
    end
  end

  // Direction Control Register (reg_gpio_dir) - Address 0x1C
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_gpio_dir <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_1C)
      reg_gpio_dir <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Power Management Register (reg_pm) - Address 0x20
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_pm <= {32{1'b0}};
    else if (write_enable_reg_20)
      reg_pm <= {pwdata[0], {31{1'b0}}};
  end

  // Interrupt Reset Register (reg_int_reset) - Address 0x24
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_reset <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_24)
      reg_int_reset <= pwdata[(GPIO_WIDTH-1):0];
  end

  //-------------------------------------------------------------------------
  // GPIO Bidirectional I/O and Synchronization
  //-------------------------------------------------------------------------
  // Capture external input from the bidirectional port
  assign gpio_in_internal = gpio;

  // Tri-state assignment for bidirectional GPIO:
  // If global power down is active (reg_pm[0] = 1), force high impedance.
  // Otherwise, if the pin is configured as output (reg_gpio_dir bit = 1) and output enable is active,
  // drive the pin with reg_dout; else leave it in high impedance.
  assign gpio = (reg_pm[0] ? 1'bz : ((reg_gpio_dir & reg_dout_en) ? reg_dout : 1'bz));

  // Input Synchronization to Avoid Metastability
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      data_in_sync1 <= {GPIO_WIDTH{1'b0}};