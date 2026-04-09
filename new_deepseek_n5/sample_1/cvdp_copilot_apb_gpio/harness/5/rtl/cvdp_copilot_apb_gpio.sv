module cvdp_copilot_apb_gpio #(
  parameter GPIO_WIDTH = 8
)
(

  // Clock and Reset Signals
  input logic pclk, 
  input logic preset_n,

  // APB Interface Inputs
  input logic psel, 
  input logic [7:2] paddr,
  input logic penable, 
  input logic pwrite,
  input logic [31:0] pwdata,
  input logic [GPIO_WIDTH-1:0] gpio_in,

  // APB Interface Outputs
  output logic [31:0] prdata,
  output logic pready,
  output logic pslverr,

  // GPIO Interface Inputs and Outputs
  input logic [GPIO_WIDTH-1:0] gpio_dir,
  output logic [GPIO_WIDTH-1:0] gpio_out,
  output logic [GPIO_WIDTH-1:0] gpio_int,
  output logic comb_int,

  // Power Management Register
  input logic preset_n_power,

  // Interrupt Reset Register
  input logic [GPIO_WIDTH-1:0] gpio_interrupt_request
);

  // Signals for Read/Write Controls
  logic read_enable;
  logic write_enable;
  logic write_enable_reg_04;
  logic write_enable_reg_08;
  logic write_enable_reg_0C;
  logic write_enable_reg_10;
  logic write_enable_reg_14;
  logic write_enable_reg_18;
  logic [GPIO_WIDTH-1:0] read_mux;
  logic [GPIO_WIDTH-1:0] read_mux_d1;

  // Control Registers
  logic [GPIO_WIDTH-1:0] reg_dout;
  logic [GPIO_WIDTH-1:0] reg_dout_en;
  logic [GPIO_WIDTH-1:0] reg_int_en;
  logic [GPIO_WIDTH-1:0] reg_int_type;
  logic [GPIO_WIDTH-1:0] reg_int_pol;
  logic [GPIO_WIDTH-1:0] reg_int_state;

  // I/O Signal Path and Interrupt Logic
  logic [GPIO_WIDTH-1:0] data_in_sync1;
  logic [GPIO_WIDTH-1:0] data_in_sync2;
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted;
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted_dly;
  logic [GPIO_WIDTH-1:0] edge_detect;
  logic [GPIO_WIDTH-1:0] raw_int;
  logic [GPIO_WIDTH-1:0] int_masked;
  logic [GPIO_WIDTH-1:0] clear_interrupt;

  // Read Operation: Multiplexing Register Data Based on Address
  always_comb begin
    case (paddr[7:2])
      6'd0: read_mux = data_in_sync2;
      6'd1: read_mux = reg_dout;
      6'd2: read_mux = reg_dout_en;
      6'd3: read_mux = reg_int_en;
      6'd4: read_mux = reg_int_type;
      6'd5: read_mux = reg_int_pol;
      6'd6: read_mux = reg_int_state;
      default: read_mux = {GPIO_WIDTH{1'b0}};
    endcase
  end

  // Registering Read Data for Timing Alignment
  always_ff @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
      read_mux_d1 <= {GPIO_WIDTH{1'b0}};
    else
      read_mux_d1 <= read_mux;
    end
  end

  // Output Read Data to APB Interface
  assign prdata = (read_enable) ? {{(32-GPIO_WIDTH){1'b0}}, read_mux_d1} : {32{1'b0}};
  assign pready = 1'b1;
  assign pslverr = 1'b0;

  // Driving GPIO Outputs and Output Enables
  assign gpio_out = reg_dout;
  assign gpio_int = reg_int_state;
  assign comb_int = |reg_int_state;

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
  assign data_in_pol_adjusted = data_in_sync2 ^ reg_int_pol;

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
  assign clear_interrupt = (pwrite & (reg_int_en)) ? 1'b1 : 0;

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

  // Power Management Register
  logic [31:0] power manages = {
    31:0,
    30:0,
    29:0,
    28:0,
    27:0,
    26:0,
    25:0,
    24: preset_n_power,
    23:0,
    22:0,
    21:0,
    20:0,
    19:0,
    18:0,
    17:0,
    16:0,
    15:0,
    14:0,
    13:0,
    12:0,
    11:0,
    10:0,
    9:0,
    8:0,
    7:0,
    6:0,
    5:0,
    4:0,
    3:0,
    2:0,
    1:0,
    0:0
  };

  // Interrupt Reset Register
  logic [GPIO_WIDTH-1:0] gpio_interrupt_request = pwrite;

  // Updated Input/Output Interfaces
  input logic [GPIO_WIDTH-1:0] gpio_interrupt_request;
  output logic [GPIO_WIDTH-1:0] clear_interrupt;