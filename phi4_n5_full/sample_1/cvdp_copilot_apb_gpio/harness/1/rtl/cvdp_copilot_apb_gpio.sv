module compliant with the Advanced Peripheral Bus (APB) protocol.
// This module supports configurable GPIO width, bidirectional control, interrupt generation
// (both edge- and level-sensitive), and robust synchronization. The design is scalable,
// well-documented, and free of ambiguities.
//
// Register Map:
//   0x00: GPIO Input Data (read-only)         -> reg_gpio_in
//   0x04: GPIO Output Data                    -> reg_gpio_out
//   0x08: GPIO Output Enable (direction)       -> reg_gpio_enable
//   0x0C: GPIO Interrupt Enable               -> reg_gpio_int_enable
//   0x10: GPIO Interrupt Type                 -> reg_gpio_int_type
//       (bit0: 0 = edge-sensitive, 1 = level-sensitive)
//   0x14: GPIO Interrupt Polarity             -> reg_gpio_int_polarity
//       (bit0: 0 = active low, 1 = active high)
//   0x18: GPIO Interrupt State (read-only)    -> reg_gpio_int_state
//
// APB Interface:
//   pclk          : Clock (rising-edge triggered)
//   preset_n      : Active-low asynchronous reset
//   psel          : APB peripheral select signal
//   paddr[5:0]    : APB address bus (only lower 6 bits used)
//   penable       : APB transfer control signal
//   pwrite        : APB write control signal
//   pwdata[31:0]  : APB write data bus
//   gpio_in[GPIO_WIDTH-1:0]: Input signals from GPIO pins
//
// Outputs:
//   prdata[31:0]  : APB read data bus (reflects register contents)
//   pready        : APB ready signal (always high)
//   pslverr       : APB error signal (always low)
//   gpio_out[GPIO_WIDTH-1:0]: Output signals to GPIO pins (driven by reg_gpio_out)
//   gpio_enable[GPIO_WIDTH-1:0]: Direction control (high = output, low = input)
//   gpio_int[GPIO_WIDTH-1:0]: Individual interrupt signals for GPIO pins
//   comb_int      : Combined interrupt signal (logical OR of all gpio_int)

module cvdp_copilot_apb_gpio #(
  parameter GPIO_WIDTH = 8
)
(
  input  logic         pclk,
  input  logic         preset_n,
  input  logic         psel,
  input  logic [5:0]   paddr,    // APB address (only lower 6 bits used)
  input  logic         penable,
  input  logic         pwrite,
  input  logic [31:0]  pwdata,
  input  logic [GPIO_WIDTH-1:0] gpio_in,
  output logic [31:0]  prdata,
  output logic         pready,
  output logic         pslverr,
  output logic [GPIO_WIDTH-1:0] gpio_out,
  output logic [GPIO_WIDTH-1:0] gpio_enable,
  output logic [GPIO_WIDTH-1:0] gpio_int,
  output logic         comb_int
);

  // Internal registers for APB registers (each 32 bits wide)
  logic [31:0] reg_gpio_in;           // 0x00: GPIO Input Data (read-only)
  logic [31:0] reg_gpio_out;          // 0x04: GPIO Output Data
  logic [31:0] reg_gpio_enable;       // 0x08: GPIO Output Enable
  logic [31:0] reg_gpio_int_enable;   // 0x0C: GPIO Interrupt Enable
  logic [31:0] reg_gpio_int_type;     // 0x10: GPIO Interrupt Type
  logic [31:0] reg_gpio_int_polarity; // 0x14: GPIO Interrupt Polarity
  logic [31:0] reg_gpio_int_state;    // 0x18: GPIO Interrupt State (read-only)

  // Two-stage synchronizers for gpio_in to mitigate metastability
  logic [GPIO_WIDTH-1:0] gpio_in_sync_stage1;
  logic [GPIO_WIDTH-1:0] gpio_in_sync_stage2;

  // APB ready and error signals (always high/low per specification)
  assign pready  = 1'b1;
  assign pslverr = 1'b0;

  // Main sequential block: clocked on rising edge of pclk, asynchronous active-low reset.
  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      // Reset all registers and synchronizers to 0
      reg_gpio_in         <= 32'd0;
      reg_gpio_out        <= 32'd0;
      reg_gpio_enable     <= 32'd0;
      reg_gpio_int_enable <= 32'd0;
      reg_gpio_int_type   <= 32'd0;
      reg_gpio_int_polarity <= 32'd0;
      reg_gpio_int_state  <= 32'd0;
      gpio_in_sync_stage1 <= '0;
      gpio_in_sync_stage2 <= '0;
    end else begin
      // Synchronize gpio_in signals through two flip-flops
      gpio_in_sync_stage1 <= gpio_in;
      gpio_in_sync_stage2 <= gpio_in_sync_stage1;
      
      // Update the read-only GPIO input register with synchronized value
      reg_gpio_in <= {24'd0, gpio_in_sync_stage2};

      // Process APB transaction only when psel and penable are asserted
      if (psel && penable) begin
        case (paddr)
          6'd0: begin
            // 0x00: GPIO Input Data (read-only) - ignore writes
          end
          6'd1: begin
            // 0x04: GPIO Output Data - update on write
            if (pwrite)
              reg_gpio_out <= pwdata;
          end
          6'd2: begin
            // 0x08: GPIO Output Enable - update on write
            if (pwrite)
              reg_gpio_enable <= pwdata;
          end
          6'd3: begin
            // 0x0C: GPIO Interrupt Enable - update on write
            if (pwrite)
              reg_gpio_int_enable <= pwdata;
          end
          6'd4: begin
            // 0x10: GPIO Interrupt Type - update on write
            if (pwrite)
              reg_gpio_int_type <= pwdata;
          end
          6'd5: begin
            // 0x14: GPIO Interrupt Polarity - update on write
            if (pwrite)
              reg_gpio_int_polarity <= pwdata;
          end
          6'd6: begin
            // 0x18: GPIO Interrupt State (read-only) - ignore writes
          end
          default: begin
            // Undefined address: no operation
          end
        endcase
      end
    end
  end

  // Drive gpio_out and gpio_enable from corresponding registers (only lower GPIO_WIDTH bits used)
  assign gpio_out   = reg_gpio_out[GPIO_WIDTH-1:0];
  assign gpio_enable = reg_gpio_enable[GPIO_WIDTH-1:0];

  // Interrupt Logic:
  // For each GPIO pin, generate an interrupt signal based on configuration.
  // reg_gpio_int_type: bit0 = 0 => edge-sensitive, 1 => level-sensitive.
  // reg_gpio_int_polarity: bit0 = 0 => active low, 1 => active high.
  // For edge-sensitive mode, detect rising or falling edge based on polarity.
  // For level-sensitive mode, assert interrupt if the input is in the active state.
  generate
    for (genvar i = 0; i < GPIO_WIDTH; i = i + 1) begin : gpio_interrupt_logic
      // Internal signals for per-pin interrupt logic
      logic current_input;
      logic previous_input;
      logic edge_detect;
      logic level_detect;
      logic int_enable;
      logic int_polarity;
      logic int_type;
      logic int_state;

      // Use synchronized inputs: current from stage2, previous from stage1
      assign current_input   = gpio_in_sync_stage2[i];
      assign previous_input  = gpio_in_sync_stage1[i];

      // Get configuration for pin i from registers
      assign int_enable  = reg_gpio_int_enable[i];
      assign int_polarity = reg_gpio_int_polarity[i];
      assign int_type    = reg_gpio_int_type[i]; // 0: edge-sensitive, 1: level-sensitive

      // Combinational logic to determine interrupt condition
      always_comb begin
        if (int_type == 1'b0) begin // Edge-sensitive mode
          if (current_input !== previous_input) begin
            if ((current_input == 1'b1) && (int_polarity == 1'b1))
              edge_detect = 1'b1;
            else if ((current_input == 1'b0) && (int_polarity == 1'b0))
              edge_detect = 1'b1;
            else
              edge_detect = 1'b0;
          end else begin
            edge_detect = 1'b0;
          end
          level_detect = 1'b0;
        end else begin // Level-sensitive mode
          if ((current_input == 1'b1) && (int_polarity == 1'b1))
            level_detect = 1'b1;
          else if ((current_input == 1'b0) && (int_polarity == 1'b0))
            level_detect = 1'b1;
          else
            level_detect = 1'b0;
          edge_detect = 1'b0;
        end
        int_state = int_enable && (edge_detect || level_detect);
      end

      // Drive individual GPIO interrupt output
      assign gpio_int[i] = int_state;

      // Update the read-only interrupt state register for pin i
      always_ff @(posedge pclk) begin
        reg_gpio_int_state[i] <= int_state;
      end
    end
  endgenerate

  // Combined interrupt signal: logical OR of all individual interrupts
  assign comb_int = |gpio_int;

  // APB Read Data Logic:
  // prdata is assigned based on the decoded APB address.
  always_comb begin
    prdata = 32'd0;  // Default value for undefined address
    case (paddr)
      6'd0: prdata = reg_gpio_in;           // 0x00: GPIO Input Data
      6'd1: prdata = reg_gpio_out;          // 0x04: GPIO Output Data
      6'd2: prdata = reg_gpio_enable;       // 0x08: GPIO Output Enable
      6'd3: prdata = reg_gpio_int_enable;   // 0x0C: GPIO Interrupt Enable
      6'd4: prdata = reg_gpio_int_type;     // 0x10: GPIO Interrupt Type
      6'd5: prdata = reg_gpio_int_polarity; // 0x14: GPIO Interrupt Polarity
      6'd6: prdata = reg_gpio_int_state;    // 0x18: GPIO Interrupt State
      default: prdata = 32'd0;
    endcase
  end

endmodule