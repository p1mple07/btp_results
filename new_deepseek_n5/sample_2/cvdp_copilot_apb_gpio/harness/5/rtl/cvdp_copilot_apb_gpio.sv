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

  // GPIO Interface Inputs and Outputs
  input logic [GPIO_WIDTH-1:0] gpio_dir,     // Direction control for each GPIO pin
  input logic [GPIO_WIDTH-1:0] gpio_in,     // GPIO input signals
  output logic [GPIO_WIDTH-1:0] gpio_out,   // GPIO output signals
  output logic [GPIO_WIDTH-1:0] gpio_enable, // GPIO output enable signals

  // Interrupt Outputs
  output logic [GPIO_WIDTH-1:0] gpio_int, // Individual interrupt outputs
  output logic comb_int                   // Combined interrupt output

  // Power Management Register
  output logic power manages; // 0x20: Power management register

  // Interrupt Reset Register
  output logic [GPIO_WIDTH-1:0] interrupt_reset; // 0x24: Interrupt reset register
);

  // Clock and Reset Signals
  input logic pclk, preset_n;
  input logic psel, [7:2] paddr, penable, pwrite, [31:0] pwdata;
  output logic [GPIO_WIDTH-1:0] gpio_out, [GPIO_WIDTH-1:0] gpio_enable, [GPIO_WIDTH-1:0] gpio_int, comb_int;
  output logic power manages, [GPIO_WIDTH-1:0] interrupt_reset;

  // Signals for Read/Write Controls
  logic read_enable;                     // Read enable signal
  logic write_enable;                    // Write enable signal
  logic write_enable_reg_04;             // Write enable for Data Output register
  logic write_enable_reg_08;             // Write enable for Output Enable register
  logic write_enable_reg_0C;             // Write enable for Interrupt Enable register
  logic write_enable_reg_10;             // Write enable for Interrupt Type register
  logic write_enable_reg_14;             // Write enable for Interrupt Polarity register
  logic write_enable_reg_18;             // Write enable for Interrupt State register
  logic [GPIO_WIDTH-1:0] read_mux;       // Read data multiplexer
  logic [GPIO_WIDTH-1:0] read_mux_d1;    // Registered read data

  // Control Registers
  logic [GPIO_WIDTH-1:0] reg_dout;       // Data Output register
  logic [GPIO_WIDTH-1:0] reg_dout_en;    // Output Enable register
  logic [GPIO_WIDTH-1:0] reg_int_en;     // Interrupt Enable register
  logic [GPIO_WIDTH-1:0] reg_int_type;   // Interrupt Type register
  logic [GPIO_WIDTH-1:0] reg_int_pol;    // Interrupt Polarity register
  logic [GPIO_WIDTH-1:0] reg_int_state;  // Interrupt State register

  // I/O Signal Path and Interrupt Logic
  logic [GPIO_WIDTH-1:0] data_in_sync1;            // First stage of input synchronization
  logic [GPIO_WIDTH-1:0] data_in_sync2;            // Second stage of input synchronization
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted;     // Polarity-adjusted input data
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted_dly; // Delayed version of polarity-adjusted input data
  logic [GPIO_WIDTH-1:0] edge_detect;              // Edge detection signals
  logic [GPIO_WIDTH-1:0] raw_int;                  // Raw interrupt signals
  logic [GPIO_WIDTH-1:0] int_masked;               // Masked interrupt signals
  logic [GPIO_WIDTH-1:0] clear_interrupt;          // Clear interrupt signals

  // Registering Read Data for Timing Alignment
  logic [GPIO_WIDTH-1:0] read_mux_d1;    // Registered read data

  // Output Read Data to APB Interface
  assign prdata = (read_enable) ? {{(32-GPIO_WIDTH){1'b0}}, read_mux_d1} : {32{1'b0}};
  assign pready = 1'b1; // Always ready
  assign pslverr = 1'b0; // No error

  // Driving GPIO Outputs and Output Enables
  assign gpio_enable = reg_dout_en; // Output enable signals
  assign gpio_out = reg_dout;       // Output data signals

  // Input Synchronization to Avoid Metastability
  logic [GPIO_WIDTH-1:0] data_in_sync1;            // First stage of input synchronization
  logic [GPIO_WIDTH-1:0] data_in_sync2;            // Second stage of input synchronization
  logic [GPIO_WIDTH-1:0] data_in_sync1 <= {GPIO_WIDTH{1'b0}};
  logic [GPIO_WIDTH-1:0] data_in_sync2 <= {GPIO_WIDTH{1'b0}};

  // Interrupt Logic

  // Adjusting Input Data Based on Interrupt Polarity
  assign data_in_pol_adjusted = data_in_sync2 ^ reg_int_pol; // Polarity adjustment

  // Registering Polarity-Adjusted Input Data and Delaying for Edge Detection
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted_dly; // Delayed version of polarity-adjusted input data

  // Edge Detection Logic for Interrupts
  assign edge_detect = data_in_pol_adjusted & (~data_in_pol_adjusted_dly); // Rising edge detection

  // Selecting Interrupt Type (Edge or Level-Triggered)
  assign raw_int = (reg_int_type & edge_detect) | (~reg_int_type & data_in_pol_adjusted); // Interrupt source

  // Applying Interrupt Enable Mask
  assign int_masked = raw_int & reg_int_en; // Masked interrupts

  // Clear Interrupt Signals
  assign clear_interrupt = (interrupt_reset & ~preset_n) | (pwdata & {GPIO_WIDTH{write_enable_reg_18}}); // Updated with new control

  // Updating Interrupt State Register (Corrected Logic)
  logic [GPIO_WIDTH-1:0] reg_int_state;  // Interrupt State register

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

  // Power Management Register
  assign power manages = 0; // Initialize to 0

  // Updated Input/Output Interfaces
  input logic [GPIO_WIDTH-1:0] gpio_dir; // Added direction control

  // Registering Read Data for Timing Alignment
  logic [GPIO_WIDTH-1:0] read_mux_d1;    // Registered read data

  // Output Read Data to APB Interface
  assign prdata = (read_enable) ? {{(32-GPIO_WIDTH){1'b0}}, read_mux_d1} : {32{1'b0}};
  assign pready = 1'b1; // Always ready
  assign pslverr = 1'b0; // No error

  // Driving GPIO Outputs and Output Enables
  assign gpio_enable = reg_dout_en; // Output enable signals
  assign gpio_out = reg_dout;       // Output data signals

  // Input Synchronization to Avoid Metastability
  logic [GPIO_WIDTH-1:0] data_in_sync1 <= {GPIO_WIDTH{1'b0}};
  logic [GPIO_WIDTH-1:0] data_in_sync2 <= {GPIO_WIDTH{1'b0}};

  // Interrupt Logic

  // Adjusting Input Data Based on Interrupt Polarity
  assign data_in_pol_adjusted = data_in_sync2 ^ reg_int_pol; // Polarity adjustment

  // Registering Polarity-Adjusted Input Data and Delaying for Edge Detection
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted_dly <= data_in_pol_adjusted;

  // Edge Detection Logic for Interrupts
  assign edge_detect = data_in_pol_adjusted & (~data_in_pol_adjusted_dly); // Rising edge detection

  // Selecting Interrupt Type (Edge or Level-Triggered)
  assign raw_int = (reg_int_type & edge_detect) | (~reg_int_type & data_in_pol_adjusted); // Interrupt source

  // Applying Interrupt Enable Mask
  assign int_masked = raw_int & reg_int_en; // Masked interrupts

  // Clear Interrupt Signals
  assign clear_interrupt = (interrupt_reset & ~preset_n) | (pwdata & {GPIO_WIDTH{write_enable_reg_18}}); // Updated with new control

  // Updating Interrupt State Register (Corrected Logic)
  logic [GPIO_WIDTH-1:0] reg_int_state;  // Interrupt State register

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

  // Power Management Register
  assign power manages = 0; // Initialize to 0

  // Updated Input/Output Interfaces
  input logic [GPIO_WIDTH-1:0] gpio_dir; // Added direction control

  // Registering Read Data for Timing Alignment
  logic [GPIO_WIDTH-1:0] read_mux_d1;    // Registered read data

  // Output Read Data to APB Interface
  assign prdata = (read_enable) ? {{(32-GPIO_WIDTH){1'b0}}, read_mux_d1} : {32{1'b0}};
  assign pready = 1'b1; // Always ready
  assign pslverr = 1'b0; // No error

  // Driving GPIO Outputs and Output Enables
  assign gpio_enable = reg_dout_en; // Output enable signals
  assign gpio_out = reg_dout;       // Output data signals

  // Input Synchronization to Avoid Metastability
  logic [GPIO_WIDTH-1:0] data_in_sync1 <= {GPIO_WIDTH{1'b0}};
  logic [GPIO_WIDTH-1:0] data_in_sync2 <= {GPIO_WIDTH{1'b0}};

  // Interrupt Logic

  // Adjusting Input Data Based on Interrupt Polarity
  assign data_in_pol_adjusted = data_in_sync2 ^ reg_int_pol; // Polarity adjustment

  // Registering Polarity-Adjusted Input Data and Delaying for Edge Detection
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted_dly <= data_in_pol_adjusted;

  // Edge Detection Logic for Interrupts
  assign edge_detect = data_in_pol_adjusted & (~data_in_pol_adjusted_dly); // Rising edge detection

  // Selecting Interrupt Type (Edge or Level-Triggered)
  assign raw_int = (reg_int_type & edge_detect) | (~reg_int_type & data_in_pol_adjusted); // Interrupt source

  // Applying Interrupt Enable Mask
  assign int_masked = raw_int & reg_int_en; // Masked interrupts

  // Clear Interrupt Signals
  assign clear_interrupt = (interrupt_reset & ~preset_n) | (pwdata & {GPIO_WIDTH{write_enable_reg_18}}); // Updated with new control

  // Updating Interrupt State Register (Corrected Logic)
  logic [GPIO_WIDTH-1:0] reg_int_state;  // Interrupt State register

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