Module: cvdp_copilot_apb_gpio
  Description:
    A GPIO module compliant with the Advanced Peripheral Bus (APB) protocol.
    It supports a configurable number of GPIO pins (default 8), bidirectional control,
    interrupt generation (both edge- and level-sensitive), and robust synchronization.
    
  Register Map (APB addresses based on paddr[7:2]):
    0x00: GPIO Input Data (read-only) - reflects the synchronized state of gpio_in.
    0x04: GPIO Output Data - drives gpio_out when the pin is configured as output.
    0x08: GPIO Output Enable - configures pin direction (high = output, low = input).
    0x0C: GPIO Interrupt Enable - enables/disables interrupts per pin.
    0x10: GPIO Interrupt Type - selects edge-sensitive (1) or level-sensitive (0) mode per pin.
    0x14: GPIO Interrupt Polarity - configures active-high (1) or active-low (0) behavior.
    0x18: GPIO Interrupt State (read-only) - reflects the current interrupt status.
    
  APB Protocol Assumptions:
    - Always-high ready (pready = 1)
    - Error-free operation (pslverr = 0)
    - Synchronous read/write operations on rising edge of pclk.
    - Asynchronous active-low reset (preset_n).
    
  Interrupt Logic:
    For each GPIO pin:
      - In level-sensitive mode (reg_inttype = 0): The interrupt is asserted if the
        synchronized input equals the active state (determined by reg_intpol).
      - In edge-sensitive mode (reg_inttype = 1): An interrupt is generated only on a
        detected edge (rising or falling) that meets the active state condition.
    The combined interrupt (comb_int) is the logical OR of all individual interrupts.
    
  Synchronization:
    Two-stage flip-flops are used to synchronize the external gpio_in to mitigate metastability.
    
  Author: [Your Name]
  Date: [Date]
*/

module cvdp_copilot_apb_gpio #(
  parameter int GPIO_WIDTH = 8
)(
  input  logic                 pclk,
  input  logic                 preset_n,
  input  logic                 psel,
  input  logic [7:0]           paddr,  // Only lower 6 bits used for address decoding.
  input  logic                 penable,
  input  logic                 pwrite,
  input  logic [31:0]          pwdata,
  input  logic [GPIO_WIDTH-1:0] gpio_in,
  output logic [31:0]          prdata,
  output logic                 pready,
  output logic                 pslverr,
  output logic [GPIO_WIDTH-1:0] gpio_out,
  output logic [GPIO_WIDTH-1:0] gpio_enable,
  output logic [GPIO_WIDTH-1:0] gpio_int,
  output logic                 comb_int
);

  //-------------------------------------------------------------------------
  // Internal Registers for APB-controlled GPIO functionality
  //-------------------------------------------------------------------------
  // 32-bit registers for each control register. Only the lower GPIO_WIDTH bits are used.
  logic [31:0] reg_gpio_out;  // GPIO Output Data Register
  logic [31:0] reg_gpio_oe;   // GPIO Output Enable Register
  logic [31:0] reg_inten;     // GPIO Interrupt Enable Register
  logic [31:0] reg_inttype;   // GPIO Interrupt Type Register (0 = level-sensitive, 1 = edge-sensitive)
  logic [31:0] reg_intpol;    // GPIO Interrupt Polarity Register (1 = active-high, 0 = active-low)
  logic [31:0] reg_intstate;  // GPIO Interrupt State Register (read-only)

  //-------------------------------------------------------------------------
  // Synchronization for gpio_in (Two-stage flip-flop)
  //-------------------------------------------------------------------------
  logic [GPIO_WIDTH-1:0] gpio_in_sync1;
  logic [GPIO_WIDTH-1:0] gpio_in_sync2;
  
  //-------------------------------------------------------------------------
  // Register to hold previous synchronized input (for edge detection)
  //-------------------------------------------------------------------------
  logic [GPIO_WIDTH-1:0] prev_gpio_in_sync;

  //-------------------------------------------------------------------------
  // APB Interface and Register Logic
  //-------------------------------------------------------------------------
  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      // Asynchronous reset: clear all registers and outputs
      reg_gpio_out  <= 32'd0;
      reg_gpio_oe   <= 32'd0;
      reg_inten     <= 32'd0;
      reg_inttype   <= 32'd0;
      reg_intpol    <= 32'd0;
      reg_intstate  <= 32'd0;
      prev_gpio_in_sync <= {GPIO_WIDTH{1'b0}};
    end else begin
      // Synchronize external gpio_in through two stages
      gpio_in_sync1 <= gpio_in;
      gpio_in_sync2 <= gpio_in_sync1;
      // Update previous synchronized input for edge detection purposes
      prev_gpio_in_sync <= gpio_in_sync2;

      // Handle APB transactions if selected and enabled
      if (psel && penable) begin
        case (paddr[7:2])
          8'h00: begin
            // GPIO Input Data Register (read-only)
            // Write operations are ignored.
          end
          8'h04: begin
            // GPIO Output Data Register: update on write.
            if (pwrite)
              reg_gpio_out[GPIO_WIDTH-1:0] <= pwdata[GPIO_WIDTH-1:0];
          end
          8'h08: begin
            // GPIO Output Enable Register: update on write.
            if (pwrite)
              reg_gpio_oe[GPIO_WIDTH-1:0] <= pwdata[GPIO_WIDTH-1:0];
          end
          8'h0C: begin
            // GPIO Interrupt Enable Register: update on write.
            if (pwrite)
              reg_inten[GPIO_WIDTH-1:0] <= pwdata[GPIO_WIDTH-1:0];
          end
          8'h10: begin
            // GPIO Interrupt Type Register: update on write.
            if (pwrite)
              reg_inttype[GPIO_WIDTH-1:0] <= pwdata[GPIO_WIDTH-1:0];
          end
          8'h14: begin
            // GPIO Interrupt Polarity Register: update on write.
            if (pwrite)
              reg_intpol[GPIO_WIDTH-1:0] <= pwdata[GPIO_WIDTH-1:0];
          end
          8'h18: begin
            // GPIO Interrupt State Register (read-only)
            // Write operations are ignored.
          end
          default: begin
            // Undefined address: no operation.
          end
        endcase
      end

      //-------------------------------------------------------------------------
      // Update GPIO Interrupt State for each pin
      //-------------------------------------------------------------------------
      for (int i = 0; i < GPIO_WIDTH; i++) begin
        if (reg_inten[i]) begin
          if (reg_inttype[i] == 1'b0) begin
            // Level-sensitive mode: Assert interrupt if input equals active state.
            reg_intstate[i] <= (gpio_in_sync2[i] == (reg_intpol[i] ? 1'b1 : 1'b0));
          end else begin
            // Edge-sensitive mode: Assert interrupt on a detected edge.
            if (gpio_in_sync2[i] != prev_gpio_in_sync[i])
              reg_intstate[i] <= (gpio_in_sync2[i] == (reg_intpol[i] ? 1'b1 : 1'b0));
            else
              reg_intstate[i] <= reg_intstate[i]; // Maintain previous state if no edge.
          end
        end else begin
          reg_intstate[i] <= 1'b0;
        end
      end
    end
  end

  //-------------------------------------------------------------------------
  // APB Response Signals
  //-------------------------------------------------------------------------
  assign pready  = 1'b1;
  assign pslverr = 1'b0;

  //-------------------------------------------------------------------------
  // Combinational Logic for APB Read Data
  //-------------------------------------------------------------------------
  always_comb begin
    // Default value for prdata.
    prdata = 32'd0;
    unique case (paddr[7:2])
      8'h00: prdata[GPIO_WIDTH-1:0] = gpio_in_sync2;           // GPIO Input Data Register
      8'h04: prdata[GPIO_WIDTH-1:0] = reg_gpio_out;              // GPIO Output Data Register
      8'h08: prdata[GPIO_WIDTH-1:0] = reg_gpio_oe;               // GPIO Output Enable Register
      8'h0C: prdata[GPIO_WIDTH-1:0] = reg_inten;                 // GPIO Interrupt Enable Register
      8'h10: prdata[GPIO_WIDTH-1:0] = reg_inttype;               // GPIO Interrupt Type Register
      8'h14: prdata[GPIO_WIDTH-1:0] = reg_intpol;                // GPIO Interrupt Polarity Register
      8'h18: prdata[GPIO_WIDTH-1:0] = reg_intstate;              // GPIO Interrupt State Register
      default: prdata = 32'd0; // Undefined address: return 0.
    endcase
  end

  //-------------------------------------------------------------------------
  // Drive GPIO Direction and Output
  //-------------------------------------------------------------------------
  // gpio_enable is directly driven by the Output Enable register.
  assign gpio_enable = reg_gpio_oe[GPIO_WIDTH-1:0];

  // gpio_int reflects the interrupt state.
  assign gpio_int = reg_intstate[GPIO_WIDTH-1:0];

  // comb_int is the logical OR of all individual interrupts.
  assign comb_int = |reg_intstate[GPIO_WIDTH-1:0];

  //-------------------------------------------------------------------------
  // Bidirectional GPIO Output with Tri-state Control
  //-------------------------------------------------------------------------
  // When gpio_enable is high, the pin is driven by reg_gpio_out.
  // When gpio_enable is low, the pin is left in high impedance.
  genvar i;
  generate
    for (i = 0; i < GPIO_WIDTH; i++) begin : gpio_out_gen
      assign gpio_out[i] = (gpio_enable[i] ? reg_gpio_out[i] : 1'bz);
    end
  endgenerate

endmodule