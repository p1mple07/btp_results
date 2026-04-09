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

  // GPIO Interface Inputs and Outputs
  input logic [GPIO_WIDTH-1:0] gpio_in,     // GPIO input signals
  output logic [GPIO_WIDTH-1:0] gpio_out,   // GPIO output signals
  output logic [GPIO_WIDTH-1:0] gpio_enable, // GPIO output enable signals

  // Interrupt Outputs
  output logic [GPIO_WIDTH-1:0] gpio_int, // Individual interrupt outputs
  output logic comb_int                   // Combined interrupt output
);

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

  // Read and Write Control Signals
  logic [GPIO_WIDTH-1:0] reg_dout;
  logic [GPIO_WIDTH-1:0] reg_dout_en;
  logic [GPIO_WIDTH-1:0] reg_int_en;
  logic [GPIO_WIDTH-1:0] reg_int_type;
  logic [GPIO_WIDTH-1:0] reg_int_pol;
  logic [GPIO_WIDTH-1:0] reg_int_state;

  // New registers
  logic [7:0] direction_control_reg = 0;
  logic [7:0] power_management_register = 0;
  logic [7:0] interrupt_reset_reg = 0;

  // Direction Control Register
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      direction_control_reg <= 0;
    else
      direction_control_reg <= gpio_dir;
  end

  // Power Management Register
  assign power_management_register = 0;
  assign power_management_register[0] = 1'b1;

  // Interrupt Reset Register
  assign interrupt_reset_reg = 0;
  assign interrupt_reset_reg[GPIO_WIDTH-1:0] = 0;

  // Existing APB logic remains unchanged
  logic [GPIO_WIDTH-1:0] data_in_sync1;
  logic [GPIO_WIDTH-1:0] data_in_sync2;
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted;
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted_dly;
  logic [GPIO_WIDTH-1:0] edge_detect;
  logic [GPIO_WIDTH-1:0] raw_int;
  logic [GPIO_WIDTH-1:0] int_masked;
  logic [GPIO_WIDTH-1:0] clear_interrupt;

  // Read and Write Control Signals
  assign read_enable = psel & (~pwrite);
  assign write_enable = psel & (~penable) & pwrite;

  // Output Enable Register (reg_dout_en)
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_dout_en <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_08)
      reg_dout_en <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Interrupt Enable Register (reg_int_en)
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_en <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_0C)
      reg_int_en <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Interrupt Type Register (reg_int_type)
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_type <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_10)
      reg_int_type <= pwdata[(GPIO_WIDTH-1):0];
  end

  // Interrupt Polarity Register (reg_int_pol)
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_pol <= {GPIO_WIDTH{1'b0}};
    else if (write_enable_reg_14)
      reg_int_pol <= pwdata[(GPIO_WIDTH-1):0];
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
  assign prdata = (read_enable) ? {{(32-GPIO_WIDTH){1'b0}}} : {32{1'b0}};
  assign pready = 1'b1;
  assign pslverr = 1'b0;

  // Driving GPIO Outputs and Output Enables
  assign gpio_enable = reg_dout_en;
  assign gpio_out = reg_dout;

  // New bidirectional GPIO support
  assign data_in_pol_adjusted = data_in_sync2 ^ direction_control_reg;
  assign data_in_pol_adjusted_dly <= data_in_pol_adjusted;

  // Interrupt Logic
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      reg_int_state <= {GPIO_WIDTH{1'b0}};
    else begin
      integer i;
      for (i = 0; i < GPIO_WIDTH; i = i + 1) begin
        if (reg_int_type[i]) begin
          if (clear_interrupt[i]) begin
            reg_int_state[i] <= 1'b0;
          end else if (int_masked[i]) begin
            reg_int_state[i] <= 1'b1;
          end
        end else begin
          reg_int_state[i] <= int_masked[i];
        end
      end
    end
  end

  // New power management control
  assign gpio_int = reg_int_state;
  assign comb_int = |reg_int_state;

endmodule
