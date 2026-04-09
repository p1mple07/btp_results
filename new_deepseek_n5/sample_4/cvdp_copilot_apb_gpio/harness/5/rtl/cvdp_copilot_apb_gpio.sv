module cvdp_copilot_apb_gpio #(
  parameter GPIO_WIDTH = 8
)
(
  // Clock and Reset Signals
  input logic pclk,       
  input logic preset_n,   
  // New GPIO control signals
  input logic [GPIO_WIDTH-1:0] gpio_interrupt_reset,
  input logic [31:0]gpio_power manages,
  // APB Interface Inputs
  input logic psel,           // Peripheral select
  input logic [7:2] paddr,    // APB address bus (bits [7:2])
  input logic penable,        // Transfer control signal
  input logic pwrite,         // Write control signal
  input logic [31:0] pwdata,  // Write data bus
  input logic [GPIO_WIDTH-1:0]gpio_in,     // GPIO input signals
  output logic [GPIO_WIDTH-1:0]gpio_out,   // GPIO output signals
  output logic [GPIO_WIDTH-1:0]gpio_dir,   // GPIO direction control
  output logic [GPIO_WIDTH-1:0]gpio_int, // Individual interrupt outputs
  output logic comb_int                   // Combined interrupt output

  // GPIO Interface Signals
  input logic [GPIO_WIDTH-1:0] [GPIO_WIDTH-1:0]gpio_dir_reg; // Direction control register
  input logic [31:0] [31:0]gpio_power manages_reg; // Power management register
  // APB Interface Outputs
  output logic [31:0] prdata, // Read data bus
  output logic [GPIO_WIDTH-1:0]gpio_int, // Device ready signal
  output logic [GPIO_WIDTH-1:0] pslverr, // Error response signal

  // GPIO Interface Input and Output
  input logic [GPIO_WIDTH-1:0] [GPIO_WIDTH-1:0]gpio_in_reg; // Input data register
  output logic [GPIO_WIDTH-1:0] [GPIO_WIDTH-1:0]gpio_out_reg; // Output data register
  output logic [GPIO_WIDTH-1:0] [GPIO_WIDTH-1:0]gpio_dir_reg; // Direction control register

  // I/O Signal Path and Interrupt Logic
  logic [GPIO_WIDTH-1:0] data_in_sync1;            // First stage of input synchronization
  logic [GPIO_WIDTH-1:0] data_in_sync2;            // Second stage of input synchronization
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted;     // Polarity-adjusted input data
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted_dly; // Delayed version of polarity-adjusted input data
  logic [GPIO_WIDTH-1:0] edge_detect;              // Edge detection signals
  logic [GPIO_WIDTH-1:0] raw_int;                  // Raw interrupt signals
  logic [GPIO_WIDTH-1:0] int_masked;               // Masked interrupt signals
  logic [GPIO_WIDTH-1:0] clear_interrupt;          // Clear interrupt signals

  // Register for Direction Control
  reg [GPIO_WIDTH-1:0] [GPIO_WIDTH-1:0]gpio_dir; // Direction control register

  // Register for Power Management
  reg [31:0] [31:0]gpio_power manages_reg; // Power management register

  // Register for Interrupt Reset
  reg [GPIO_WIDTH-1:0] [GPIO_WIDTH-1:0]gpio_int_reset; // Interrupt reset register

  // Signals for Read/Write Controls
  logic read_enable;                     // Read enable signal
  logic write_enable;                    // Write enable signal
  logic write_enable_reg_04;            // Write enable for Data Output register
  logic write_enable_reg_08;            // Write enable for Output Enable register
  logic write_enable_reg_0C;            // Write enable for Interrupt Enable register
  logic write_enable_reg_10;            // Write enable for Interrupt Type register
  logic write_enable_reg_14;            // Write enable for Interrupt Polarity register
  logic write_enable_reg_18;            // Write enable for Interrupt State register

  // Control Registers
  logic [GPIO_WIDTH-1:0] reg_dout;       // Data Output register
  logic [GPIO_WIDTH-1:0] reg_dout_en;    // Output Enable register
  logic [GPIO_WIDTH-1:0] reg_int_en;     // Interrupt Enable register
  logic [GPIO_WIDTH-1:0] reg_int_type;   // Interrupt Type register
  logic [GPIO_WIDTH-1:0] reg_int_pol;    // Interrupt Polarity register
  logic [GPIO_WIDTH-1:0] reg_int_state;  // Interrupt State register

  // I/O Signal Path and Interrupt Logic
  logic [GPIO_WIDTH-1:0] case (paddr[7:2])
      6'd0: read_mux = data_in_sync2;   // Input Data Register at address 0x00
      6'd1: read_mux = reg_dout;        // Data Output Register at address 0x04
      6'd2: read_mux = reg_dout_en;     // Output Enable Register at address 0x08
      6'd3: read_mux = reg_int_en;      // Interrupt Enable Register at address 0x0C
      6'd4: read_mux = reg_int_type;    // Interrupt Type Register at address 0x10
      6'd5: read_mux = reg_int_pol;     // Interrupt Polarity Register at address 0x14
      6'd6: read_mux = reg_int_state;   // Interrupt State Register at address 0x18
      default: read_mux = {GPIO_WIDTH{1'b0}}; // Default to zeros if address is invalid
    endcase

  // Registering Read Data for Timing Alignment
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      read_mux_d1 <= {GPIO_WIDTH{1'b0}};
    else
      read_mux_d1 <= read_mux;
  end

  // Output Read Data to APB Interface
  assign prdata = (read_enable) ? {{(32-GPIO_WIDTH){1'b0}}, read_mux_d1} : {32{1'b0}};
  assign pready = 1'b1; // Always ready
  assign pslverr = 1'b0; // No error

  // Driving GPIO Outputs and Output Enables
  assign gpio_out = reg_dout;       // Output data signals
  assign gpio_out_dir = reg_dout;   // Output direction signals
  assigngpio_power manages = reg_power manages; // Output power management signals

  // Input Synchronization to Avoid Metastability
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      data_in_sync1 <= {GPIO_WIDTH{1'b0}};
      data_in_sync2 <= {GPIO_WIDTH{1'b0}};
    end else begin
      data_in_sync1 <= gpio_in;
      data_in_sync2 <= data_in_sync1;
    end
  end

  // Interrupt Logic

  // Adjusting Input Data Based on Interrupt Polarity
  assign data_in_pol_adjusted = data_in_sync2 ^ reg_int_pol; // Polarity adjustment

  // Registering Polarity-Adjusted Input Data and Delaying for Edge Detection
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      data_in_pol_adjusted_dly <= {GPIO_WIDTH{1'b0}};
    end else begin
      data_in_pol_adjusted_dly <= data_in_pol_adjusted;
    end
  end

  // Edge Detection Logic for Interrupts
  assign edge_detect = data_in_pol_adjusted & (~data_in_pol_adjusted_dly); // Rising edge detection

  // Selecting Interrupt Type (Edge or Level-Triggered)
  assign raw_int = (reg_int_type & edge_detect) | (~reg_int_type & data_in_pol_adjusted); // Interrupt source

  // Applying Interrupt Enable Mask
  assign int_masked = raw_int & reg_int_en; // Masked interrupts

  // Clear Interrupt Signals
  assign clear_interrupt = (gpio_interrupt_reset) & (pwrite) & (pwdata[GPIO_WIDTH-1:0]); // Clear all active interrupts

  // Updating Interrupt State Register (Corrected Logic)
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      reg_int_state <= {GPIO_WIDTH{1'b0}};
    end else begin
      integer i;
      for (i = 0; i < GPIO_WIDTH; i = i + 1) begin
        if (reg_int_type[i]) begin
          // Edge-triggered interrupt
          if (clear_interrupt[i]) begin
            reg_int_state[i] <= 1'b0;
          end else if (int_masked[i]) begin
            reg_int_state[i] <= 1'b1;
          end
        end else begin
          // Level-triggered interrupt
          reg_int_state[i] <= int_masked[i];
        end
      end
    end
  end

  // Connecting Interrupt Outputs
  assign gpio_int = reg_int_state;     // Individual interrupt outputs
  assign comb_int = |reg_int_state;    // Combined interrupt output

  // Updating Direction Control Register
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      reg_gpio_dir <= {GPIO_WIDTH{1'b0}};
    end else begin
      integer i;
      for (i = 0; i < GPIO_WIDTH; i = i + 1) begin
        reg_gpio_dir[i] = (pwrite & (psel == 6'd1)) ? 1'b1 : 0;
      end
    end
  end

  // New Register Declaration
  reg [31:0] [31:0]gpio_power manages_reg; // Power management register
  reg [GPIO_WIDTH-1:0] [GPIO_WIDTH-1:0]gpio_dir_reg; // Direction control register
  reg [GPIO_WIDTH-1:0] [GPIO_WIDTH-1:0]gpio_int_reset_reg; // Interrupt reset register

  // Register Initialization
  initial begin
    // Reset all registers to default values
    reg_dout = {GPIO_WIDTH{1'b0}};
    reg_dout_en = {GPIO_WIDTH{1'b0}};
    reg_int_en = {GPIO_WIDTH{1'b0}};
    reg_int_type = {GPIO_WIDTH{1'b0}};
    reg_int_pol = {GPIO_WIDTH{1'b0}};
    reg_int_state = {GPIO_WIDTH{1'b0}};
    reg_power manages = {31:0}{0};
    reg_gpio_dir = {GPIO_WIDTH{1'b0}};
    reg_int_reset = {GPIO_WIDTH{1'b0}};
    // Initialize new registers
    reg_gpio_dir_reg = {GPIO_WIDTH{1'b0}};
    reg_gpio_power manages_reg = {31:0}{0};
    reg_gpio_int_reset_reg = {GPIO_WIDTH{1'b0}};
  end