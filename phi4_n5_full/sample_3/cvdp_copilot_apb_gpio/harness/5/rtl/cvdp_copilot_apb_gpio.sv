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

  // APB Interface Outputs
  output logic [31:0] prdata, // Read data bus
  output logic pready,        // Device ready signal
  output logic pslverr,       // Device error response

  // GPIO Interface Inputs and Outputs (Bidirectional)
  inout logic [GPIO_WIDTH-1:0] gpio,    // Bidirectional GPIO pins

  // Interrupt Outputs
  output logic [GPIO_WIDTH-1:0] gpio_int, // Individual interrupt outputs
  output logic comb_int                   // Combined interrupt output
);

  // Internal signals for Read/Write Controls
  logic read_enable;                     
  logic write_enable;                    
  logic write_enable_reg_04;             
  logic write_enable_reg_08;             
  logic write_enable_reg_0C;             
  logic write_enable_reg_10;             
  logic write_enable_reg_14;             
  logic write_enable_reg_18;             
  logic write_enable_reg_1C;             // New: Direction Control Register (0x1C)
  logic write_enable_reg_20;             // New: Power Management Register (0x20)
  logic write_enable_reg_24;             // New: Interrupt Reset Register (0x24)
  logic [GPIO_WIDTH-1:0] read_mux;       
  logic [GPIO_WIDTH-1:0] read_mux_d1;    

  // Control Registers
  logic [GPIO_WIDTH-1:0] reg_dout;       // Data Output register
  logic [GPIO_WIDTH-1:0] reg_dout_en;    // Output Enable register
  logic [GPIO_WIDTH-1:0] reg_int_en;     // Interrupt Enable register
  logic [GPIO_WIDTH-1:0] reg_int_type;   // Interrupt Type register
  logic [GPIO_WIDTH-1:0] reg_int_pol;    // Interrupt Polarity register
  logic [GPIO_WIDTH-1:0] reg_int_state;  // Interrupt State register

  // New Registers
  logic [GPIO_WIDTH-1:0] reg_dir;        // Direction Control Register (0x1C)
  logic [31:0] reg_pm;                   // Power Management Register (0x20)
  logic [GPIO_WIDTH-1:0] reg_int_reset;  // Interrupt Reset Register (0x24)

  // I/O Signal Path and Interrupt Logic
  logic [GPIO_WIDTH-1:0] data_in_sync1;            
  logic [GPIO_WIDTH-1:0] data_in_sync2;            
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted;     
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted_dly; 
  logic [GPIO_WIDTH-1:0] edge_detect;              
  logic [GPIO_WIDTH-1:0] raw_int;                  
  logic [GPIO_WIDTH-1:0] int_masked;               
  logic [GPIO_WIDTH-1:0] clear_interrupt;          
  logic [GPIO_WIDTH-1:0] clear_interrupt_reg;      // (From previous write to 0x18)

  // Read and Write Control Signals
  assign read_enable = psel & (~pwrite); // Read enable
  assign write_enable = psel & (~penable) & pwrite; // Write enable

  // Write Enable Signals for Specific Registers
  assign write_enable_reg_04 = write_enable & (paddr[7:2] == 6'd1); // Address 0x04
  assign write_enable_reg_08 = write_enable & (paddr[7:2] == 6'd2); // Address 0x08
  assign write_enable_reg_0C = write_enable & (paddr[7:2] == 6'd3); // Address 0x0C
  assign write_enable_reg_10 = write_enable & (paddr[7:2] == 6'd4); // Address 0x10
  assign write_enable_reg_14 = write_enable & (paddr[7:2] == 6'd5); // Address 0x14
  assign write_enable_reg_18 = write_enable & (paddr[7:2] == 6'd6); // Address 0x18

  // New Write Enable Signals for Added Registers
  assign write_enable_reg_1C = write_enable & (paddr[7:2] == 6'd7); // Address 0x1C: Direction Control
  assign write_enable_reg_20 = write_enable & (paddr[7:2] == 6'd8); // Address 0x20: Power Management
  assign write_enable_reg_24 = write_enable & (paddr[7:2] == 6'd9); // Address 0x24: Interrupt Reset

  // Write Operations for Control Registers

  // Data Output Register (reg_dout) at 0x04
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_dout <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_04)
      reg_dout <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Output Enable Register (reg_dout_en) at 0x08
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_dout_en <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_08)
      reg_dout_en <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Interrupt Enable Register (reg_int_en) at 0x0C
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_en <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_0C)
      reg_int_en <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Interrupt Type Register (reg_int_type) at 0x10
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_type <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_10)
      reg_int_type <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Interrupt Polarity Register (reg_int_pol) at 0x14
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_pol <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_14)
      reg_int_pol <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Interrupt State Register (reg_int_state) at 0x18
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      reg_int_state <= {GPIO_WIDTH{1'b0}};
    end else begin
      integer i;
      for (i = 0; i < GPIO_WIDTH; i = i + 1) begin
        // Software-controlled reset has highest priority
        if (reg_int_reset[i])
          reg_int_state[i] <= 1'b0;
        else if (reg_int_type[i]) begin
          // Edge-triggered interrupt
          if (clear_interrupt[i])
            reg_int_state[i] <= 1'b0;
          else if (int_masked[i])
            reg_int_state[i] <= 1'b1;
        end else begin
          // Level-triggered interrupt
          reg_int_state[i] <= int_masked[i];
        end
      end
    end
  end

  // New Register: Direction Control Register (reg_dir) at 0x1C
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_dir <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_1C)
      reg_dir <= pwdata[(GPIO_WIDTH-1):0];
  end

  // New Register: Power Management Register (reg_pm) at 0x20
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_pm <= {1'b0, 31'b0};
    else if (write_enable_reg_20)
      // Only bit[0] is used; ignore bits[31:1]
      reg_pm <= {31'b0, pwdata[0]};
  end

  // New Register: Interrupt Reset Register (reg_int_reset) at 0x24
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_reset <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_24)
      reg_int_reset <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Read Operation: Multiplexing Register Data Based on Address
  always_comb begin
    case (paddr[7:2])
      6'd0: read_mux = data_in_sync2;   // Input Data Register at address 0x00
      6'd1: read_mux = reg_dout;        // Data Output Register at address 0x04
      6'd2: read_mux = reg_dout_en;     // Output Enable Register at address 0x08
      6'd3: read_mux = reg_int_en;      // Interrupt Enable Register at address 0x0C
      6'd4: read_mux = reg_int_type;    // Interrupt Type Register at address 0x10
      6'd5: read_mux = reg_int_pol;     // Interrupt Polarity Register at address 0x14
      6'd6: read_mux = reg_int_state;   // Interrupt State Register at address 0x18
      6'd7: read_mux = reg_dir;         // Direction Control Register at address 0x1C
      6'd8: read_mux = reg_pm;          // Power Management Register at address 0x20
      6'd9: read_mux = reg_int_reset;   // Interrupt Reset Register at address 0x24
      default: read_mux = {GPIO_WIDTH{1'b0}}; // Default to zeros if address is invalid
    endcase
  end

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
  assign gpio_enable = reg_dout_en; // Output enable signals

  // Bidirectional GPIO Output with Direction and Power Management
  // When a pin is configured as output (reg_dir[i] == 1) and global power is enabled (reg_pm[0] == 0),
  // the output is driven by reg_dout. Otherwise, the pin is left in high impedance.
  genvar i;
  generate
    for (i = 0; i < GPIO_WIDTH; i = i + 1) begin : gpio_out_gen
      assign gpio[i] = (reg_pm[0] ? 1'bz : ((reg_dir[i] == 1) ? reg_dout[i] : 1'bz));
    end
  endgenerate

  // Input Synchronization to Avoid Metastability
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      data_in_sync1 <= {GPIO_WIDTH{1'b0}};
      data_in_sync2 <= {GPIO_WIDTH{1'b0}};
    end else begin
      data_in_sync1 <= gpio;  // Note: using bidirectional gpio_in now comes from 'gpio'
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

  // Clear Interrupt Signals (from previous write to 0x18)
  assign clear_interrupt = pwdata[GPIO_WIDTH-1:0] & {GPIO_WIDTH{write_enable_reg_18}};

  // Connecting Interrupt Outputs
  assign gpio_int = reg_int_state;     // Individual interrupt outputs
  assign comb_int = |reg_int_state;    // Combined interrupt output

endmodule