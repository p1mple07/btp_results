module cvdp_copilot_apb_gpio #(
  parameter GPIO_WIDTH = 8
)(
  // Clock and Reset Signals
  input logic pclk,       // Clock signal
  input logic preset_n,   // Active-low reset signal
  input logic psel,           // Peripheral select
  input logic [7:2] paddr,    // APB address bus (bits [7:2])
  input logic penable,        // Transfer control signal
  input logic pwrite,         // Write control signal
  input logic [31:0] pwdata,  // Write data bus
  input logic [GPIO_WIDTH-1:0] gpio_dir, // Direction control for each GPIO
  // New Power Management Register
  input logic power manageset, // Bit[0]: Global power-down
  // New Interrupt Reset Register
  input logic [GPIO_WIDTH-1:0] interrupt_reset, // Bit[0-GPIO_WIDTH-1]: Reset each pin's interrupt
  // GPIO Interface Inputs and Outputs
  input logic [GPIO_WIDTH-1:0] gpio_in,     // GPIO input signals
  output logic [GPIO_WIDTH-1:0] gpio_out,   // GPIO output signals
  output logic [GPIO_WIDTH-1:0] gpio_int,   // Individual interrupt outputs
  output logic comb_int                   // Combined interrupt output
);

  // Existing signals and logic
  // ... (keep all existing code until the end of the file) ...

  // New Register Definitions
  logic [GPIO_WIDTH-1:0] reg_gpio_dir = gpio_dir; // Mirrored from input

  // Power Management Register
  logic power manage En = (power manageset); // Global power-down enabled

  // Interrupt Reset Register
  logic [GPIO_WIDTH-1:0] reg_interrupt_reset = interrupt_reset;

  // Modified Read/Write Control Signals
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      read_mux_d1 <= {GPIO_WIDTH{1'b0}};
    else begin
      read_mux_d1 <= read_mux;
    end
  end

  // Modified Read Operation: Multiplexing Register Data Based on Address
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

  // Modified Registering Read Data for Timing Alignment
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      read_mux_d1 <= {GPIO_WIDTH{1'b0}};
    else
      read_mux_d1 <= read_mux;
    end
  end

  // Modified Output Read Data to APB Interface
  assign prdata = (read_enable) ? {{(32-GPIO_WIDTH){1'b0}}, read_mux_d1} : {32{1'b0}};
  assign pready = 1'b1; // Always ready
  assign pslverr = 1'b0; // No error

  // Modified Driving GPIO Outputs and Output Enables
  assign gpio_enable = reg_dout_en; // Output enable signals
  assign gpio_out = reg_dout;       // Output data signals

  // Modified Input Synchronization to Avoid Metastability
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      data_in_sync1 <= {GPIO_WIDTH{1'b0}};
      data_in_sync2 <= {GPIO_WIDTH{1'b0}};
    end else begin
      data_in_sync1 <= gpio_in;
      data_in_sync2 <= data_in_sync1;
    end
  end

  // Modified Interrupt Logic

  // Modified Adjusting Input Data Based on Interrupt Polarity
  assign data_in_pol_adjusted = data_in_sync2 ^ reg_int_pol; // Polarity adjustment

  // Modified Registering Polarity-Adjusted Input Data and Delaying for Edge Detection
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n) begin
      data_in_pol_adjusted_dly <= {GPIO_WIDTH{1'b0}};
    end else begin
      data_in_pol_adjusted_dly <= data_in_pol_adjusted;
    end
  end

  // Modified Edge Detection Logic for Interrupts
  assign edge_detect = data_in_pol_adjusted & (~data_in_pol_adjusted_dly); // Rising edge detection

  // Modified Selecting Interrupt Type (Edge or Level-Triggered)
  assign raw_int = (reg_int_type & edge_detect) | (~reg_int_type & data_in_pol_adjusted); // Interrupt source

  // Modified Applying Interrupt Enable Mask
  assign int_masked = raw_int & reg_int_en; // Masked interrupts

  // Modified Clear Interrupt Signals
  assign clear_interrupt = (pwrite & (reg_int_type & (1 << (31 - 31)))) | ( ~pwrite & (reg_int_type & (1 << (31 - 31)))); // Simplified clear_interrupt

  // Modified Updating Interrupt State Register (Corrected Logic)
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

  // Modified Connecting Interrupt Outputs
  assign gpio_int = reg_int_state;     // Individual interrupt outputs
  assign comb_int = |reg_int_state;    // Combined interrupt output

endmodule