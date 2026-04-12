// cvdp_copilot_apb_gpio.v

module cvdp_copilot_apb_gpio #(
  parameter GPIO_WIDTH = 8
)(
  // Clock and Reset Signals
  input wire pclk,       // Clock signal
  input wire preset_n,   // Active-low reset signal

  // APB Interface Inputs
  input wire psel,           // Peripheral select
  input wire [7:2] paddr,    // APB address bus (bits [7:2])
  input wire penable,        // Transfer control signal
  input wire pwrite,         // Write control signal
  input wire [31:0] pwdata,  // Write data bus

  // APB Interface Outputs
  output reg [31:0] prdata, // Read data bus
  output wire pready,        // Device ready signal
  output wire pslverr,       // Device error response

  // Bidirectional GPIO Interface
  inout wire [GPIO_WIDTH-1:0] gpio, // Bidirectional GPIO pins

  // Interrupt Outputs
  output reg [GPIO_WIDTH-1:0] gpio_int, // Individual interrupt outputs
  output reg comb_int                   // Combined interrupt output
);

  // Signals for Read/Write Controls
  wire read_enable;                     // Read enable signal
  wire write_enable;                    // Write enable signal
  reg write_enable_reg_04;              // Write enable for Data Output register
  reg write_enable_reg_08;              // Write enable for Output Enable register
  reg write_enable_reg_0C;              // Write enable for Interrupt Enable register
  reg write_enable_reg_10;              // Write enable for Interrupt Type register
  reg write_enable_reg_14;              // Write enable for Interrupt Polarity register
  reg write_enable_reg_18;              // Write enable for Interrupt State register
  reg write_enable_reg_1C;              // Write enable for Direction Control register
  reg write_enable_reg_20;              // Write enable for Power Down register
  reg write_enable_reg_24;              // Write enable for Interrupt Control register
  reg [GPIO_WIDTH-1:0] read_mux;        // Read data multiplexer
  reg [GPIO_WIDTH-1:0] read_mux_d1;     // Registered read data

  // Control Registers
  reg [GPIO_WIDTH-1:0] reg_dout;        // Data Output register
  reg [GPIO_WIDTH-1:0] reg_dout_en;     // Output Enable register (kept for compatibility)
  reg [GPIO_WIDTH-1:0] reg_int_en;      // Interrupt Enable register
  reg [GPIO_WIDTH-1:0] reg_int_type;    // Interrupt Type register
  reg [GPIO_WIDTH-1:0] reg_int_pol;     // Interrupt Polarity register
  reg [GPIO_WIDTH-1:0] reg_int_state;   // Interrupt State register
  reg [GPIO_WIDTH-1:0] reg_gpio_dir;    // Direction Control register (1: output, 0: input)
  reg reg_power_down;                   // Power Down register
  reg reg_int_ctrl;                     // Interrupt Control register

  // I/O Signal Path and Interrupt Logic
  reg [GPIO_WIDTH-1:0] data_in_sync1;            // First stage of input synchronization
  reg [GPIO_WIDTH-1:0] data_in_sync2;            // Second stage of input synchronization
  wire [GPIO_WIDTH-1:0] data_in_pol_adjusted;    // Polarity-adjusted input data
  reg [GPIO_WIDTH-1:0] data_in_pol_adjusted_dly; // Delayed version of polarity-adjusted input data
  wire [GPIO_WIDTH-1:0] edge_detect;             // Edge detection signals
  wire [GPIO_WIDTH-1:0] raw_int;                 // Raw interrupt signals
  wire [GPIO_WIDTH-1:0] int_masked;              // Masked interrupt signals
  wire [GPIO_WIDTH-1:0] clear_interrupt;         // Clear interrupt signals

  // Internal Signals
  wire module_active;                 // Module active signal based on power-down
  wire [GPIO_WIDTH-1:0] gpio_in_int;  // Internal GPIO input signals

  // Read and Write Control Signals
  assign read_enable = psel & (~pwrite); // Read enable
  assign write_enable = psel & (~penable) & pwrite; // Write enable

  // Write Enable Signals for Specific Registers
  always @(*) begin
    write_enable_reg_04 = write_enable & (paddr[7:2] == 6'd1);  // Address 0x04
    write_enable_reg_08 = write_enable & (paddr[7:2] == 6'd2);  // Address 0x08
    write_enable_reg_0C = write_enable & (paddr[7:2] == 6'd3);  // Address 0x0C
    write_enable_reg_10 = write_enable & (paddr[7:2] == 6'd4);  // Address 0x10
    write_enable_reg_14 = write_enable & (paddr[7:2] == 6'd5);  // Address 0x14
    write_enable_reg_18 = write_enable & (paddr[7:2] == 6'd6);  // Address 0x18
    write_enable_reg_1C = write_enable & (paddr[7:2] == 6'd7);  // Address 0x1C
    write_enable_reg_20 = write_enable & (paddr[7:2] == 6'd8);  // Address 0x20
    write_enable_reg_24 = write_enable & (paddr[7:2] == 6'd9);  // Address 0x24
  end

  // Module Active Signal Based on Power-Down Register
  assign module_active = ~reg_power_down;

  // Write Operations for Control Registers

  // Data Output Register (reg_dout)
  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_dout <= {GPIO_WIDTH{1'b0}};
    else if (module_active) begin
      if (write_enable_reg_04)
        reg_dout <= pwdata[(GPIO_WIDTH-1):0];
    end
  end

  // Output Enable Register (reg_dout_en) - Kept for Compatibility
  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_dout_en <= {GPIO_WIDTH{1'b0}};
    else if (module_active) begin
      if (write_enable_reg_08)
        reg_dout_en <= pwdata[(GPIO_WIDTH-1):0];
    end
  end

  // Interrupt Enable Register (reg_int_en)
  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_en <= {GPIO_WIDTH{1'b0}};
    else if (module_active) begin
      if (write_enable_reg_0C)
        reg_int_en <= pwdata[(GPIO_WIDTH-1):0];
    end
  end

  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_type <= {GPIO_WIDTH{1'b0}};
    else if (module_active) begin
      if (write_enable_reg_10)
        reg_int_type <= pwdata[(GPIO_WIDTH-1):0];
    end
  end

  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_pol <= {GPIO_WIDTH{1'b0}};
    else if (module_active) begin
      if (write_enable_reg_14)
        reg_int_pol <= pwdata[(GPIO_WIDTH-1):0];
    end
  end

  // Direction Control Register (reg_gpio_dir)
  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_gpio_dir <= {GPIO_WIDTH{1'b0}};
    else if (module_active) begin
      if (write_enable_reg_1C)
        reg_gpio_dir <= pwdata[(GPIO_WIDTH-1):0];
    end
  end

  // Power Down Register (reg_power_down)
  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_power_down <= 1'b0;
    else begin
      if (write_enable_reg_20)
        reg_power_down <= pwdata[0];
    end
  end

  // Interrupt Control Register (reg_int_ctrl)
  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_ctrl <= 1'b0;
    else begin
      if (write_enable_reg_24)
        reg_int_ctrl <= pwdata[0];
      else
        reg_int_ctrl <= 1'b0; // Auto-clear after use
    end
  end

  // Read Operation: Multiplexing Register Data Based on Address
  always @(*) begin
    case (paddr[7:2])
      6'd0: read_mux = data_in_sync2;   // Input Data Register at address 0x00
      6'd1: read_mux = reg_dout;        // Data Output Register at address 0x04
      6'd2: read_mux = reg_dout_en;     // Output Enable Register at address 0x08
      6'd3: read_mux = reg_int_en;      // Interrupt Enable Register at address 0x0C
      6'd4: read_mux = reg_int_type;    // Interrupt Type Register at address 0x10
      6'd5: read_mux = reg_int_pol;     // Interrupt Polarity Register at address 0x14
      6'd6: read_mux = reg_int_state;   // Interrupt State Register at address 0x18
      6'd7: read_mux = reg_gpio_dir;    // Direction Control Register at address 0x1C
      6'd8: read_mux = {{(GPIO_WIDTH-1){1'b0}}, reg_power_down}; // Power Down Register at address 0x20
      6'd9: read_mux = {{(GPIO_WIDTH-1){1'b0}}, reg_int_ctrl};   // Interrupt Control Register at address 0x24
      default: read_mux = {GPIO_WIDTH{1'b0}}; // Default to zeros if address is invalid
    endcase
  end

  // Registering Read Data for Timing Alignment
  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      read_mux_d1 <= {GPIO_WIDTH{1'b0}};
    else
      read_mux_d1 <= read_mux;
  end

  // Output Read Data to APB Interface
  always @(*) begin
    if (read_enable)
      prdata = {{(32-GPIO_WIDTH){1'b0}}, read_mux_d1};
    else
      prdata = {32{1'b0}};
  end

  assign pready = 1'b1; // Always ready
  assign pslverr = 1'b0; // No error

  // Driving GPIO Outputs and Direction Control
  genvar i;
  generate
    for (i = 0; i < GPIO_WIDTH; i = i + 1) begin : gpio_buffer
      assign gpio[i] = (reg_gpio_dir[i] && module_active) ? reg_dout[i] : 1'bz; // Drive when output
    end
  endgenerate

  assign gpio_in_int = gpio; // Read the gpio pins

  // Input Synchronization to Avoid Metastability
  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      data_in_sync1 <= {GPIO_WIDTH{1'b0}};
      data_in_sync2 <= {GPIO_WIDTH{1'b0}};
    end else begin
      data_in_sync1 <= gpio_in_int;
      data_in_sync2 <= data_in_sync1;
    end
  end

  assign data_in_pol_adjusted = ~(data_in_sync2 ^ reg_int_pol); 

  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      data_in_pol_adjusted_dly <= {GPIO_WIDTH{1'b0}};
    end else begin
      data_in_pol_adjusted_dly <= data_in_pol_adjusted;
    end
  end

  assign edge_detect = data_in_pol_adjusted & (~data_in_pol_adjusted_dly); // Rising edge detection

  assign raw_int = (reg_int_type & edge_detect) | (~reg_int_type & data_in_pol_adjusted); // Interrupt source

  // Applying Interrupt Enable Mask
  assign int_masked = raw_int & reg_int_en; // Masked interrupts

  // Clear Interrupt Signals
  assign clear_interrupt = pwdata[GPIO_WIDTH-1:0] & {GPIO_WIDTH{write_enable_reg_18}};

  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      reg_int_state <= {GPIO_WIDTH{1'b0}};
    end else begin
      integer idx;
      for (idx = 0; idx < GPIO_WIDTH; idx = idx + 1) begin
        if (~module_active) begin
          // Clear interrupt state when module is inactive
          reg_int_state[idx] <= 1'b0;
        end else if (reg_int_ctrl) begin
          // Software-controlled reset for all interrupts
          reg_int_state[idx] <= 1'b0;
        end else begin
          if (reg_int_type[idx]) begin
            // Edge-triggered interrupt
            if (clear_interrupt[idx]) begin
              reg_int_state[idx] <= 1'b0;
            end else if (int_masked[idx]) begin
              reg_int_state[idx] <= 1'b1;
            end
          end else begin
            // Level-triggered interrupt
            reg_int_state[idx] <= int_masked[idx];
          end
        end
      end
    end
  end

  always @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      gpio_int <= {GPIO_WIDTH{1'b0}};
      comb_int <= 1'b0;
    end else begin
      gpio_int <= reg_int_state;     // Individual interrupt outputs
      comb_int <= |reg_int_state;    // Combined interrupt output
    end
  end

endmodule