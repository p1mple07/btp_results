module cvdp_copilot_apb_gpio #(
  parameter GPIO_WIDTH = 8
)(
  // Clock and Reset Signals
  input  logic pclk,       
  input  logic preset_n,   

  // APB Interface Inputs
  input  logic psel,           
  input  logic [7:2] paddr,    
  input  logic penable,        
  input  logic pwrite,         
  input  logic [31:0] pwdata,  

  // Bidirectional GPIO Port (updated to support input and output)
  inout  logic [GPIO_WIDTH-1:0] gpio,  

  // APB Interface Outputs
  output logic [31:0] prdata,       
  output logic pready,        
  output logic pslverr,       

  // Interrupt Outputs
  output logic [GPIO_WIDTH-1:0] gpio_int,     
  output logic comb_int                  
);

  //-------------------------------------------------------------------------
  // Internal Signal for Bidirectional GPIO Capture
  // Capture the external value when gpio is not driven.
  wire [GPIO_WIDTH-1:0] gpio_buf;
  assign gpio_buf = gpio;

  //-------------------------------------------------------------------------
  // APB Read/Write Control Signals
  logic read_enable;                     
  logic write_enable;                    
  // Write enable signals for existing registers
  logic write_enable_reg_04;             
  logic write_enable_reg_0C;             
  logic write_enable_reg_10;             
  logic write_enable_reg_14;             
  logic write_enable_reg_18;             
  // Write enable signals for new registers
  logic write_enable_reg_1C;             
  logic write_enable_reg_20;             
  logic write_enable_reg_24;             

  //-------------------------------------------------------------------------
  // Control Registers
  logic [GPIO_WIDTH-1:0] reg_dout;       // Data Output register (0x04)
  // Removed reg_dout_en – direction control now replaces output enable.
  logic [GPIO_WIDTH-1:0] reg_dir;        // Direction Control Register (0x1C)
  logic [GPIO_WIDTH-1:0] reg_int_en;     // Interrupt Enable register (0x0C)
  logic [GPIO_WIDTH-1:0] reg_int_type;   // Interrupt Type register (0x10)
  logic [GPIO_WIDTH-1:0] reg_int_pol;    // Interrupt Polarity register (0x14)
  logic [GPIO_WIDTH-1:0] reg_int_state;  // Interrupt State register (0x18)
  // New registers:
  logic [31:0] reg_power;                // Power Management Register (0x20)
  logic [GPIO_WIDTH-1:0] reg_int_reset;  // Interrupt Reset Register (0x24)

  //-------------------------------------------------------------------------
  // I/O Signal Path and Interrupt Logic
  logic [GPIO_WIDTH-1:0] data_in_sync1;            
  logic [GPIO_WIDTH-1:0] data_in_sync2;            
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted;     
  logic [GPIO_WIDTH-1:0] data_in_pol_adjusted_dly; 
  logic [GPIO_WIDTH-1:0] edge_detect;              
  logic [GPIO_WIDTH-1:0] raw_int;                  
  logic [GPIO_WIDTH-1:0] int_masked;               
  logic [GPIO_WIDTH-1:0] clear_interrupt;          

  //-------------------------------------------------------------------------
  // APB Read/Write Control
  assign read_enable = psel & (~pwrite); // Read enable
  assign write_enable = psel & (~penable) & pwrite; // Write enable

  // Write enable signals based on APB address decoding:
  assign write_enable_reg_04 = write_enable & (paddr[7:2] == 6'd1); // Address 0x04
  assign write_enable_reg_0C = write_enable & (paddr[7:2] == 6'd3); // Address 0x0C
  assign write_enable_reg_10 = write_enable & (paddr[7:2] == 6'd4); // Address 0x10
  assign write_enable_reg_14 = write_enable & (paddr[7:2] == 6'd5); // Address 0x14
  assign write_enable_reg_18 = write_enable & (paddr[7:2] == 6'd6); // Address 0x18
  assign write_enable_reg_1C = write_enable & (paddr[7:2] == 6'd7); // Address